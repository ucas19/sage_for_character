# sage_vector_store.py
import sqlite3
import hashlib
import json
from contextlib import contextmanager

# 注意：此模块需在 SageMath 环境中运行（如 sage -python）
# 因为它依赖 sage.all

try:
    from sage.all import QQ, vector
except ImportError:
    raise ImportError("This module must be run in a SageMath environment (e.g., sage -python).")

def _sage_vector_to_str(v):
    """
    将 SageMath 向量转换为规范字符串表示。
    例如: vector(QQ, [1, -2, 3/5]) -> "(1, -2, 3/5)"
    """
    return str(v)

def _str_to_sage_vector(s, base_ring=QQ):
    """
    安全地将字符串解析回 SageMath 向量（不使用 eval）。
    输入格式必须是 Sage 的标准向量字符串，如 "(1, -2, 3/5)"。
    """
    s = s.strip()
    if not (s.startswith('(') and s.endswith(')')):
        raise ValueError(f"Invalid vector string format: {s}")
    inner = s[1:-1].strip()
    if inner == '':
        coords = []
    else:
        # 分割并逐个转换为 base_ring 元素（如 QQ）
        coords = [base_ring(x.strip()) for x in inner.split(',')]
    return vector(base_ring, coords)

def _compute_vector_hash(v):
    """计算 Sage 向量的 SHA256 哈希（用于快速去重和索引）"""
    s = _sage_vector_to_str(v).encode('utf-8')
    return hashlib.sha256(s).hexdigest()

class SageVectorGroupStore:
    """
    存储以 SageMath 向量为键的向量组。
    每个“键向量”唯一标识一个“向量组”（list of vectors）。
    所有数据持久化到 SQLite 数据库。
    """

    def __init__(self, db_path='sage_vector_groups.db'):
        self.db_path = db_path
        self._init_db()

    def _init_db(self):
        """初始化数据库表"""
        with self._get_connection() as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS vector_groups (
                    hash TEXT PRIMARY KEY,
                    key_vector_str TEXT NOT NULL UNIQUE,
                    group_vectors_json TEXT NOT NULL
                )
            ''')
            conn.commit()

    @contextmanager
    def _get_connection(self):
        """提供带自动提交/回滚的连接上下文"""
        conn = sqlite3.connect(self.db_path)
        try:
            yield conn
        except Exception:
            conn.rollback()
            raise
        else:
            conn.commit()
        finally:
            conn.close()

    def add_group(self, key_vector, group_vectors):
        """
        添加一个新的向量组。
        :param key_vector: SageMath vector (e.g., vector(QQ, [1,2,3]))
        :param group_vectors: list of SageMath vectors
        :raises ValueError: 如果 key_vector 已存在
        """
        if not isinstance(group_vectors, (list, tuple)):
            raise TypeError("group_vectors must be a list or tuple of vectors")

        key_str = _sage_vector_to_str(key_vector)
        group_json = json.dumps([_sage_vector_to_str(v) for v in group_vectors])
        h = _compute_vector_hash(key_vector)

        try:
            with self._get_connection() as conn:
                conn.execute(
                    "INSERT INTO vector_groups (hash, key_vector_str, group_vectors_json) VALUES (?, ?, ?)",
                    (h, key_str, group_json)
                )
        except sqlite3.IntegrityError:
            raise ValueError(f"Key vector {key_vector} already exists")

    def remove_group(self, key_vector):
        """
        删除指定键向量对应的组。
        :param key_vector: SageMath vector
        :raises KeyError: 如果键不存在
        """
        h = _compute_vector_hash(key_vector)
        with self._get_connection() as conn:
            cur = conn.execute("DELETE FROM vector_groups WHERE hash = ?", (h,))
            if cur.rowcount == 0:
                raise KeyError(f"Key vector {key_vector} not found")

    def exists(self, key_vector):
        """
        检查键向量是否存在。
        :return: bool
        """
        h = _compute_vector_hash(key_vector)
        with self._get_connection() as conn:
            cur = conn.execute("SELECT 1 FROM vector_groups WHERE hash = ?", (h,))
            return cur.fetchone() is not None

    def get_group(self, key_vector):
        """
        获取键向量对应的向量组。
        :return: list of SageMath vectors, or None if not found
        """
        h = _compute_vector_hash(key_vector)
        with self._get_connection() as conn:
            cur = conn.execute("SELECT group_vectors_json FROM vector_groups WHERE hash = ?", (h,))
            row = cur.fetchone()
            if row is None:
                return None
            vec_strs = json.loads(row[0])
            return [_str_to_sage_vector(s) for s in vec_strs]

    def list_keys(self):
        """
        （可选）列出所有键向量（用于调试）
        :return: list of SageMath vectors
        """
        with self._get_connection() as conn:
            cur = conn.execute("SELECT key_vector_str FROM vector_groups")
            return [_str_to_sage_vector(row[0]) for row in cur.fetchall()]

    def close(self):
        """兼容接口（实际无需显式关闭，因使用上下文管理器）"""
        pass
