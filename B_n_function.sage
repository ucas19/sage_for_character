# 设置李代数类型和秩
# 导入必要的模块
from sage.groups.perm_gps.permgroup_named import SymmetricGroup
from sage.groups.perm_gps.permgroup import PermutationGroup
from sage.groups.abelian_gps.abelian_group import AbelianGroup
from sage.combinat.root_system.weyl_group import WeylGroup
from sage.matrix.constructor import diagonal_matrix, identity_matrix
from sage.modules.free_module_element import vector
from SemidirectProductGroup import SemidirectProductGroup

print("✅ 正在使用 SageMath 版本:", sage.version.version)

n = 2
m = 1
# R = RootSystem(['B', n])
W = WeylGroup(['B', n], prefix="w")  # Weyl群，生成元命名为 s1, s2, ...
# L = R.weight_lattice()
# fund_weights = L.fundamental_weights()



print(f"✅ W(B{n}) 群：{W}")
print(f"阶数: {W.cardinality()}")

print("\n所有元素及其矩阵表示：")
for w in W:
    mat = w.to_matrix()
    print(f"{w} ↦\n{mat}")

Z2_n = AbelianGroup([2]*n, names = "e")
print(f"✅ (Z₂)^n = {Z2_n}")
print(f"生成元: {Z2_n.gens()}")
print(f"所有元素: {list(Z2_n)}")

S_n = SymmetricGroup(n)
# s = S2.gen(0)  # (1,2)
print(f"✅ S_{n}的阶 = {S_n.order()}")
print(f"元素: {list(S_n)}")

# 半直积群的阶应该是 2^n * n!
expected_order = 2**n * factorial(n)
print(f"半直积群预期阶: {expected_order}")
print(f"Weyl 群实际阶: {W.order()}")
print(f"阶数是否匹配: {W.order() == expected_order}\n")

# 手动创建半直积群 (Z_2)^n ⋊ S_n 的元素列表
semidirect_elements = []
for epsilon in Z2_n:
    for sigma in S_n:
        semidirect_elements.append((epsilon, sigma))

#def semidirect_multiply(el1, el2):
#        epsilon1, sigma1 = el1
#        epsilon2, sigma2 = el2
#        print(el1,el2)
#        # 计算 σ₁(ε₂)
#        sigma1_inv = sigma1_inverse()
#        eps2_list = list(epsilon2.list())
#        twisted_eps2_list = [eps2_list[sigma1_inv(i+1)-1] for i in range(len(eps2_list))]
#        twisted_eps2 = Z2_n(twisted_eps2_list)
#        
#        # 计算 ε₁ + σ₁(ε₂)
#        eps1_list = list(epsilon1.list())
#        twisted_eps2_list = list(twisted_eps2.list())
#        new_epsilon = Z2_n([(eps1_list[i] + twisted_eps2_list[i]) % 2 for i in range(len(eps1_list))])
#        
#        # 计算 σ₁σ₂
#        new_sigma = sigma1 * sigma2
#        
#        return (new_epsilon, new_sigma)



        
G = SemidirectProductGroup(Z2_n, S_n)
print(f"✅ 半直积群 G = (Z₂)^{n} ⋊ S_{n}，阶数: {len(G.elements)}")
print("所有元素 (epsilon, sigma):")
for elem in G.elements:
    print(f"  {elem}")



coeffs = vector(QQ , [3/2, 1/2])  # 必须是非负整数（支配整权）
lmbda = coeffs

print("λ =", lmbda)

def bn_to_semidirect(w,m,Z2_n,S_n):
    # 获取 w 的矩阵表示
   #mat = w.to_matrix()
    v = vector(QQ, range(1,m+1))
    # 提取符号改变信息
    w_inv = w.inverse()
    result_inv = w_inv.to_matrix() * v
    result = w.to_matrix() * v
#    print(f" {w_inv.to_matrix()} * {v} = {result_inv}")
    epsilon = []
    for i in range(m):
        if result[i] > 0:
            epsilon.append(0)  # 无符号改变
        else:  # mat[i, i] == -1
            epsilon.append(1)  # 有符号改变
    #print(result,epsilon)
    # 提取置换信息
    abs_values = [abs(x) for x in result]
    # 创建置换
    sigma = S_n(abs_values)
#    print(f"{sigma}")
    return (Z2_n(epsilon), sigma.inverse())

def semidirect_to_bn(sd_element, W):
    epsilon, sigma = sd_element
    n = len(epsilon.list())
    
    # 将 AbelianGroup 元素转换为列表
    eps_list = epsilon.list()
#    print(f"测试{eps_list}")
    #print(sigma)
    # 创建对角矩阵（符号改变部分）
    #diag_mat = diagonal_matrix([1 if e == 0 else -1 for e in eps_list])
    #print((f"eps_list={eps_list}"))
    # 创建置换矩阵
    perm_mat = matrix(n, n, 0)
    for i in range(n):
        j = sigma(i+1) - 1  # S_n 中的元素作用于 1..n，矩阵索引是 0..n-1
        perm_mat[j, i] = (-1)**eps_list[j]
#        print(f"{j},{i},{perm_mat[j,i]}")
#        print(f"{i+1} {j+1}")
#    print(f"矩阵是\n{ perm_mat}")
    # 在 Weyl 群中找到对应的元素
    for w in W:
        if w.to_matrix() == perm_mat:
            return w
    return None  # 如果找不到（理论上不应该发生）

#w1 = W.simple_reflection(1)
#w2 = W.simple_reflection(2)
#w3 = W.simple_reflection(3)
#w = w3*w2*w3*w1*w2*w3*w1
#sd = bn_to_semidirect(w,n,Z2_n,S_n)
#w_back = semidirect_to_bn(sd,W)
#print(f"{w} -> {sd} -> {w_back} (测试: {w == w_back})")

for w in list(W):
    sd = bn_to_semidirect(w,n,Z2_n,S_n)
#    print(sd)
    w_back = semidirect_to_bn(sd,W)

    sd_back = bn_to_semidirect(w_back,n,Z2_n,S_n)

    if(w_back==w and sd==sd_back ):
        print(f"{w} -> {sd} -> {w_back} (一致: {w == w_back})")
        continue
    else:
        print(f"{w} -> {sd} -> {w_back} (不一致: {w == w_back})")
#        print(w.matrix())
#        print(w_back.matrix())


"""
验证同构：保持群运算
"""

"""
print("✅ 开始验证同构性（保持乘法）...")

is_homomorphism = True
for w1 in W:
    for w2 in W:
        # W 中乘积
        w_product = w1 * w2
        g_expected = bn_to_semidirect(w_product,n,Z2_n,S_n)

        # G 中乘积
        g1 = bn_to_semidirect(w1,n,Z2_n,S_n)
        g2 = bn_to_semidirect(w2,n,Z2_n,S_n)
#       p print(f"{g1}{g2}")
        g_computed = G.mul(g1,g2)

        if g_expected != g_computed:
            print(f"❌ 失败: {w1} * {w2} = {w_product}")
            print(f"   期望 G 中: {g_expected}")
            print(f"   实际 G 中: {g_computed}")
            is_homomorphism = False
            break
    if not is_homomorphism:
        break

if is_homomorphism:
    print("✅ 同构验证通过！W(B₂) ≅ (Z₂)² ⋊ S₂")
else:
    print("❌ 同构验证失败。")
"""

#delta_add_delta = []
#delta_minus_delta = []
#double_delta = []
#epsilon = []
#for i in range(n):
#    epsilon = 
#







for g in G:
    epsilon, sigma = g
    eps_list = epsilon.list()
    flag = 0
    for i in range(n):
        


