from ortools.linear_solver import pywraplp
import numpy as np

def is_nonnegative_integer_combination(A, A_list):
    """
    检查向量 A 是否可以表示为 A_list 中向量的非负整数线性组合（系数不全为零）。
    
    参数:
        A: 目标向量 (list 或 np.array)
        A_list: 向量列表 [A1, A2, ..., Ak]，每个与 A 同维度
    
    返回:
        bool: 如果存在这样的非负整数系数返回 True，否则 False
        coefficients: 如果存在，返回系数列表 [c1, c2, ...]；否则返回 None
    """
    A = np.array(A, dtype=float)
    A_list = [np.array(Ai, dtype=float) for Ai in A_list]
    d = len(A)  # 向量维度
    k = len(A_list)  # 向量个数
    
    # 创建求解器
    solver = pywraplp.Solver.CreateSolver('SCIP')
    if not solver:
        raise RuntimeError("SCIP solver not available")
    
    # 定义变量：非负整数
    c = [solver.IntVar(0, solver.infinity(), f'c_{j}') for j in range(k)]
    
    # 添加等式约束：每个分量
    for i in range(d):
        # 创建约束：sum(c_j * A_list[j][i]) = A[i]
        constraint_expr = sum(c[j] * A_list[j][i] for j in range(k))
        solver.Add(constraint_expr == float(A[i]))
    
    # 系数不全为零：至少一个系数 >= 1
    solver.Add(sum(c) >= 1)
    
    # 求解
    status = solver.Solve()
    
    if status == pywraplp.Solver.OPTIMAL or status == pywraplp.Solver.FEASIBLE:
        coefficients = [int(c[j].solution_value()) for j in range(k)]
        return True, coefficients
    else:
        return False, None

# 更简单的版本，使用 CBC 求解器（通常更可靠）
def is_nonnegative_integer_combination_simple(A, A_list):
    """
    简化版本，使用 CBC 求解器
    """
    A = np.array(A, dtype=float)
    A_list = [np.array(Ai, dtype=float) for Ai in A_list]
    d = len(A)
    k = len(A_list)
    
    # 使用 CBC 求解器
    solver = pywraplp.Solver.CreateSolver('CBC')
    if not solver:
        # 如果 CBC 不可用，尝试 SCIP
        solver = pywraplp.Solver.CreateSolver('SCIP')
        if not solver:
            raise RuntimeError("No suitable solver available")
    
    # 定义非负整数变量
    c = [solver.IntVar(0, solver.infinity(), f'c_{j}') for j in range(k)]
    
    # 添加等式约束
    for i in range(d):
        constraint = solver.Constraint(float(A[i]), float(A[i]))
        for j in range(k):
            constraint.SetCoefficient(c[j], float(A_list[j][i]))
    
    # 系数不全为零
    sum_constraint = solver.Constraint(1.0, solver.infinity())
    for j in range(k):
        sum_constraint.SetCoefficient(c[j], 1.0)
    
    # 求解
    status = solver.Solve()
    
    if status == pywraplp.Solver.OPTIMAL or status == pywraplp.Solver.FEASIBLE:
        coefficients = [int(c[j].solution_value()) for j in range(k)]
        return True, coefficients
    else:
        return False, None

# 测试函数
def test_combination(A, A_list, use_simple=True):
    """
    测试函数，方便验证结果
    """
    if use_simple:
        possible, coeffs = is_nonnegative_integer_combination_simple(A, A_list)
    else:
        possible, coeffs = is_nonnegative_integer_combination(A, A_list)
    
    print(f"目标向量 A: {A}")
    print(f"基向量列表: {A_list}")
    print(f"是否可以表示: {possible}")
    
    if possible:
        print(f"系数: {coeffs}")
        # 验证结果
        result = np.zeros_like(A, dtype=float)
        for i, (c_val, vec) in enumerate(zip(coeffs, A_list)):
            result += c_val * np.array(vec)
        print(f"验证结果: {result}")
        print(f"目标向量: {A}")
        print(f"是否匹配: {np.allclose(result, A)}")
    else:
        print("无法用非负整数系数表示")
    print("-" * 50)

# 示例测试
#if __name__ == "__main__":
#    print("测试1: 可以表示的情况")
#    A1 = [7, 10]
#    A_list1 = [
#        [1, 2],
#        [3, 4]
#    ]
#    test_combination(A1, A_list1)
#    
#    print("测试2: 不能表示的情况")
#    A2 = [1, 1]
#    A_list2 = [
#        [2, 0],
#        [0, 2]
#    ]
#    test_combination(A2, A_list2)
#    
#    print("测试3: 零向量的特殊情况")
#    A3 = [0, 0]
#    A_list3 = [
#        [1, 0],
#        [0, 1]
#    ]
#    test_combination(A3, A_list3)
#    
#    print("测试4: 三维向量测试")
#    A4 = [5, 7, 9]
#    A_list4 = [
#        [1, 1, 1],
#        [2, 2, 2],
#        [1, 2, 3]
#    ]
#    test_combination(A4, A_list4)
