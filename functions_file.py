from typing import Counter
from Mu_with_message import Mu_With_Message
from weyl_group_Bn import Weyl_Group_Bn
from sage.groups.perm_gps.permgroup_named import SymmetricGroup
from sage.rings.rational_field import QQ
from lowest_module import Lowest_Module
from integer_com import is_nonnegative_integer_combination_simple
from sage_integer_com import is_nonnegative_integer_combination_sage
from Mu_with_message import *
from sage.all import *
from sage.all import QQ, vector

# 读取test.txt文件并将每一行转换为有理数向量
def parse_vector(line):
    """
    解析包含在 () 或 [] 中的向量，返回有理数向量
    """
    # 移除空格
    line = line.replace(' ', '')
    
    # 检查是否被 () 或 [] 包围
    if (line.startswith('(') and line.endswith(')')) or (line.startswith('[') and line.endswith(']')):
        # 提取括号内的内容
        content = line[1:-1]
        
        # 按逗号分割元素
        elements = content.split(',')
        
        # 转换为有理数并创建向量
        vector_elements = [QQ(element) for element in elements]
        
        return vector(QQ,vector_elements)
    else:
        raise ValueError(f"无效的向量格式: {line}")

def read_vectors_from_file(filename):
    """
    从文件中读取所有向量
    """
    vectors = []
    
    try:
        with open(filename, 'r') as file:
            for line_num, line in enumerate(file, 1):
                line = line.strip()
                if not line:  # 跳过空行
                    continue
                
                # 处理一行中可能有多个向量的情况
                # 使用正则表达式分割不同的向量
                import re
                # 匹配 () 或 [] 包围的向量
                vector_strings = re.findall(r'[(\[].*?[)\]]', line)
                
                for vector_str in vector_strings:
                    try:
                        vec = parse_vector(vector_str)
                        vectors.append(vec)
                        print(f"成功解析向量: {vec}")
                    except Exception as e:
                        print(f"第 {line_num} 行解析错误 '{vector_str}': {e}")
    
    except FileNotFoundError:
        print(f"错误: 文件 '{filename}' 未找到")
        return []
    print("全部解析成功")
    return vectors

# 主程序

def read_rational_vectors(filename):
    """
    读取文件并将每一行转换为有理数向量
    
    参数:
    filename: 文件名
    
    返回:
    包含有理数向量的列表
    """
    vectors = []
    
    try:
        with open(filename, 'r') as file:
            for line_num, line in enumerate(file, 1):
                # 去除行首尾的空白字符
                line = line.strip()
                
                # 跳过空行
                if not line:
                    continue
                
                try:
                    # 分割字符串 - 支持逗号、空格等多种分隔符
                    # 使用正则表达式分割，处理多种分隔符情况
                    import re
                    elements = re.split(r'[,，\s]+', line)
                    
                    # 过滤空字符串并转换为有理数
                    rational_elements = []
                    for elem in elements:
                        elem = elem.strip()
                        if elem:  # 非空字符串
                            rational_elements.append(QQ(elem))
                    
                    # 创建有理数向量
                    print(rational_elements)
                    if rational_elements:
                        vectorr = vector(QQ, rational_elements)
                        vectors.append(vectorr)
                        print(f"第{line_num}行成功转换为向量: {vectorr}")
                    else:
                        print(f"警告: 第{line_num}行没有有效数字")
                        
                except Exception as e:
                    print(f"错误: 第{line_num}行处理失败 - {e}")
                    print(f"行内容: '{line}'")
                    
    except FileNotFoundError:
        print(f"错误: 文件 '{filename}' 未找到")
        return []
    except Exception as e:
        print(f"读取文件时发生错误: {e}")
        return []
    
    return vectors

# 主程序
