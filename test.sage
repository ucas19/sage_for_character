
from sage.numerical.mip import MIPSolverException
from functions_file import *
from sage.all import *
def is_nonnegative_integer_combination_sage(A, A_list):
    """
    检查 SageMath 向量 A 是否可以表示为 A_list 中向量的非负整数线性组合（系数不全为零）。
    
    参数:
        A: 目标向量 (SageMath vector)
        A_list: 向量列表 [A1, A2, ..., Ak] (SageMath vectors)
    
    返回:
        bool: 如果存在这样的非负整数系数返回 True，否则 False
        coefficients: 如果存在，返回系数列表 [c1, c2, ...]；否则返回 None
    """
    # 创建混合整数线性规划问题
    p = MixedIntegerLinearProgram(maximization=False, solver="GLPK")
    
    # 定义非负整数变量
    k = len(A_list)
    c = p.new_variable(integer=True, nonnegative=True)
    
    # 添加等式约束：每个分量
    d = len(A)  # 向量维度
    for i in range(d):
        # sum(c_j * A_list[j][i]) = A[i]
        p.add_constraint(sum(c[j] * A_list[j][i] for j in range(k)) == A[i])
    
    # 系数不全为零：至少一个系数 >= 1
    p.add_constraint(sum(c[j] for j in range(k)) >= 1)
    
    try:
        # 我们不需要优化目标，只需要检查可行性
        # 设置一个常数的目标函数
        p.set_objective(sum(c[j] for j in range(k)))
        
        # 求解
        p.solve()
        
        # 获取解
        coefficients = [p.get_values(c[j]) for j in range(k)]
        
        # 检查解是否真的是整数（由于数值精度，可能需要取整）
        coefficients = [int(round(val)) for val in coefficients]
        
        # 验证解是否正确
        result = sum(coefficients[j] * A_list[j] for j in range(k))
        if result == A and any(coefficients):  # 确保不全为零
            return True, coefficients
        else:
            return False, None
            
    except MIPSolverException:
        # 无可行解
        return False, None

# 更稳健的版本，处理数值精度问题
def is_nonnegative_integer_combination_sage_robust(A, A_list, tolerance=1e-6):
    """
    稳健版本，处理数值精度问题
    """
    p = MixedIntegerLinearProgram(maximization=False, solver="GLPK")
    k = len(A_list)
    c = p.new_variable(integer=True, nonnegative=True)
    d = len(A)
    
    # 添加等式约束（带容差）
    for i in range(d):
        expr = sum(c[j] * A_list[j][i] for j in range(k))
        p.add_constraint(expr >= A[i] - tolerance)
        p.add_constraint(expr <= A[i] + tolerance)
    
    # 系数不全为零
    p.add_constraint(sum(c[j] for j in range(k)) >= 1)
    
    # 目标函数：最小化系数和（有助于找到稀疏解）
    p.set_objective(sum(c[j] for j in range(k)))
    
    try:
        p.solve()
        coefficients = [int(round(p.get_values(c[j]))) for j in range(k)]
        
        # 精确验证
        result = sum(coefficients[j] * A_list[j] for j in range(k))
        if result == A and any(coefficients):
            return True, coefficients
        else:
            return False, None
            
    except MIPSolverException:
        return False, None

# 测试函数
def test_sage_combination(A, A_list, use_robust=False):
    """
    测试 SageMath 向量版本的函数
    """
    if use_robust:
        possible, coeffs = is_nonnegative_integer_combination_sage_robust(A, A_list)
    else:
        possible, coeffs = is_nonnegative_integer_combination_sage(A, A_list)
    
    print(f"目标向量 A: {A}")
    print(f"基向量列表: {A_list}")
    print(f"是否可以表示: {possible}")
    
    if possible:
        print(f"系数: {coeffs}")
        # 验证结果
        result = sum(coeffs[j] * A_list[j] for j in range(len(A_list)))
        print(f"验证结果: {result}")
        print(f"是否匹配: {result == A}")
        print(f"系数是否不全为零: {any(coeffs)}")
    else:
        print("无法用非负整数系数表示")
    print("-" * 50)

# 示例测试
def testsssss():
    # 创建 SageMath 向量
    print("测试1: 可以表示的情况")
    A1 = vector(ZZ, [7, 10])  # ZZ 表示整数环
    A_list1 = [
        vector(ZZ, [1, 2]),
        vector(ZZ, [3, 4])
    ]
    test_sage_combination(A1, A_list1)
    
    print("测试2: 不能表示的情况")
    A2 = vector(ZZ, [1, 1])
    A_list2 = [
        vector(ZZ, [2, 0]),
        vector(ZZ, [0, 2])
    ]
    test_sage_combination(A2, A_list2)
    
    print("测试3: 零向量的特殊情况")
    A3 = vector(ZZ, [0, 0])
    A_list3 = [
        vector(ZZ, [1, 0]),
        vector(ZZ, [0, 1])
    ]
    test_sage_combination(A3, A_list3)
    
    print("测试4: 需要多个系数的情况")
    A4 = vector(ZZ, [5, 7, 9])
    A_list4 = [
        vector(ZZ, [1, 1, 1]),
        vector(ZZ, [1, 2, 3]),
        vector(ZZ, [2, 2, 2])
    ]
    test_sage_combination(A4, A_list4)
    
    print("测试5: 有理数向量测试")
    A5 = vector(QQ, [5/2, 7/2])  # QQ 表示有理数域
    A_list5 = [
        vector(QQ, [1, 2]),
        vector(QQ, [2, 1])
    ]
    test_sage_combination(A5, A_list5, use_robust=True)




if __name__ == "__main__":
    filename = "test//test.txt"
    
    print(f"正在读取文件: {filename}")
    vectors = read_vectors_from_file(filename)
    
    print(f"\n总共解析了 {len(vectors)} 个向量:")
    for i, vec in enumerate(vectors, 1):
        print(f"向量 {i}: {vec} (类型: {type(vec)})")
    
    # 示例：对向量进行操作
    if len(vectors) >= 2:
        print(f"\n向量运算示例:")
        print(f"向量1 + 向量2 = {vectors[0] + vectors[1]}")
        print(f"向量1 · 向量2 = {vectors[0].dot_product(vectors[1])}")

