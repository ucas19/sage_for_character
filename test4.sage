from sage_vector_store import SageVectorGroupStore
from sage.all import vector, QQ

# 创建存储
store = SageVectorGroupStore('my_vectors.db')

# 定义向量
key1 = vector(QQ, [1, 2, 3])
group1 = [
    vector(QQ, [1, 0]),
    vector(QQ, [0, 1, 1/2])
]

# 添加
store.add_group(key1, group1)

# 检查存在
print(store.exists(key1))  # True

# 查询
retrieved = store.get_group(key1)
print(retrieved)  # [ (1, 0), (0, 1, 1/2) ]

# 尝试重复添加 → 报错
try:
    store.add_group(key1, group1)
except ValueError as e:
    print(e)  # Key vector ... already exists

# 删除
store.remove_group(key1)
print(store.exists(key1))  # False

# 列出所有键（调试用）
# print(store.list_keys())
