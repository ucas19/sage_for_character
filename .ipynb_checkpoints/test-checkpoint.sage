# 导入必要的模块
from sage.groups.perm_gps.permgroup_named import SymmetricGroup
from sage.groups.perm_gps.permgroup import PermutationGroup
from sage.groups.abelian_gps.abelian_group import AbelianGroup
from sage.combinat.root_system.weyl_group import WeylGroup
from sage.groups.group_semidirect_product import SemidirectProduct

# 定义 ;B₂ Weyl 群
W = WeylGroup(['B', 2])
print("B₂ Weyl 群元素:")
for w in W:
    print(f"{w} -> 矩阵表示: {w.to_matrix()}")

# 定义 (Z₂)²
Z2_sq = AbelianGroup([2, 2])
print(f"\n(Z₂)² 元素: {list(Z2_sq)}")

# 定义 S₂
S2 = SymmetricGroup(2)
print(f"S₂ 元素: {list(S2)}")

# 定义 S₂ 在 (Z₂)² 上的作用
def twist_action(sigma, epsilon):
    # sigma 作用在 epsilon 上：σ(ε₁, ε₂) = (ε_{σ(1)}, ε_{σ(2)})
    if sigma == S2.identity():
        return epsilon
    else:  # sigma 是交换 (1,2)
        # 将 AbelianGroup 元素转换为元组以便操作
        eps_tuple = tuple(epsilon.list())
        # 交换坐标
        twisted = (eps_tuple[1], eps_tuple[0])
        # 转换回 AbelianGroup 元素
        return Z2_sq(twisted)

# 创建半直积群 (Z₂)² ⋊ S₂
semidirect = SemidirectProduct(Z2_sq, S2, twist_action, prefix1='e', prefix2='s')
print(f"\n半直积群 (Z₂)² ⋊ S₂ 元素: {list(semidirect)}")

# 定义从 B₂ 到半直积群的映射
def b2_to_semidirect(w):
    # 获取 w 的矩阵表示
    mat = w.to_matrix()
    
    # 提取符号改变信息
    epsilon = []
    for i in range(2):
        if mat[i, i] == 1:
            epsilon.append(0)  # 无符号改变
        else:  # mat[i, i] == -1
            epsilon.append(1)  # 有符号改变
    
    # 提取置换信息
    if mat[0, 1] == 0 and mat[1, 0] == 0:  # 对角矩阵，无置换
        sigma = S2.identity()
    else:  # 非对角矩阵，有置换
        sigma = S2([(1,2)])
    
    # 创建半直积群元素
    return semidirect((Z2_sq(epsilon), sigma))

# 定义从半直积群到 B₂ 的映射
def semidirect_to_b2(sd_element):
    # 提取符号改变和置换信息
    epsilon, sigma = sd_element.cartesian_projection()
    
    # 将 AbelianGroup 元素转换为列表
    eps_list = list(epsilon.list())
    
    # 创建对角矩阵（符号改变部分）
    diag_mat = diagonal_matrix([1 if e == 0 else -1 for e in eps_list])
    
    # 创建置换矩阵
    if sigma == S2.identity():
        perm_mat = identity_matrix(2)
    else:  # sigma 是交换 (1,2)
        perm_mat = matrix([[0, 1], [1, 0]])
    
    # 组合得到完整的变换矩阵
    full_mat = diag_mat * perm_mat
    
    # 在 Weyl 群中找到对应的元素
    for w in W:
        if w.to_matrix() == full_mat:
            return w
    
    return None  # 如果找不到（理论上不应该发生）

# 测试映射
print("\nB₂ 到半直积群的映射:")
for w in W:
    sd = b2_to_semidirect(w)
    print(f"{w} -> {sd}")

print("\n半直积群到 B₂ 的映射:")
for sd in semidirect:
    w = semidirect_to_b2(sd)
    print(f"{sd} -> {w}")

# 验证同构：检查映射是否保持群运算
print("\n验证同构:")
for w1 in W:
    for w2 in W:
        # 在 B₂ 中计算乘积
        product_b2 = w1 * w2
        
        # 在半直积群中计算对应元素的乘积
        sd1 = b2_to_semidirect(w1)
        sd2 = b2_to_semidirect(w2)
        product_sd = sd1 * sd2
        
        # 将半直积群的乘积映射回 B₂
        product_sd_to_b2 = semidirect_to_b2(product_sd)
        
        # 检查是否一致
        if product_b2 != product_sd_to_b2:
            print(f"错误: {w1} * {w2} = {product_b2}, 但映射得到 {product_sd_to_b2}")
            break
    else:
        continue
    break
else:
    print("同构验证通过!")
