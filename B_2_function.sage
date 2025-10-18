# %pip install sage  # 如果未安装 Sage，但在非原生环境运行（如 CoCalc 无需）

"""
from sage.combinat.root_system.weyl_group import WeylGroup
from sage.groups.abelian_gps.abelian_group import AbelianGroup
from sage.groups.perm_gps.permgroup_named import SymmetricGroup
from sage.matrix.constructor import diagonal_matrix, matrix
from sage.rings.integer_ring import ZZ
"""
from SemidirectProductGroup import SemidirectProductGroup

print("✅ 正在使用 SageMath 版本:", sage.version.version)

W = WeylGroup(['B', 2], prefix='w')
print(f"✅ W(B₂) 群：{W}")
print(f"阶数: {W.cardinality()}")

print("\n所有元素及其矩阵表示：")
for w in W:
    mat = w.to_matrix()
    print(f"{w} ↦\n{mat}")


Z2 = AbelianGroup([2, 2], names='e')
e1, e2 = Z2.gens()
print(f"✅ (Z₂)² = {Z2}")
print(f"生成元: {e1}, {e2}")
print(f"所有元素: {list(Z2)}")

S2 = SymmetricGroup(2)
s = S2.gen(0)  # (1,2)
print(f"✅ S₂ = {S2}")
print(f"元素: {list(S2)}")

"""5
构造S_2的作用
"""
def twist_action(sigma, epsilon):
    """
    S2 在 (Z2)^2 上的作用：σ.(ε₁, ε₂) = (ε_{σ⁻¹(1)}, ε_{σ⁻¹(2)})
    注意：Sage 中作用通常是左作用，我们定义 σ(ε) = (ε[σ(1)-1], ε[σ(2)-1])
    """
    eps_tuple = epsilon.list()  # 如 [0,1]
    if sigma == S2.identity():
        return epsilon
    else:
        # 交换：σ = (1,2) ⇒ 新顺序: (ε2, ε1)
        return Z2((eps_tuple[1], eps_tuple[0]))


# 构造半直积群
G = SemidirectProductGroup(Z2, S2, twist_action)
print(f"✅ 半直积群 G = (Z₂)² ⋊ S₂，阶数: {len(G.elements)}")
print("所有元素 (epsilon, sigma):")
for elem in G.elements:
    print(f"  {elem}")



# 构造半直积群
G = SemidirectProductGroup(Z2, S2, twist_action)
print(f"✅ 半直积群 G = (Z₂)² ⋊ S₂，阶数: {len(G.elements)}")
print("所有元素 (epsilon, sigma):")
for elem in G.elements:
    print(f"  {elem}")


"""
定义W(B_2)→G的同构映射
"""
def b2_to_g(w):
    e1 = vector(ZZ, [1, 0])
    e2 = vector(ZZ, [0, 1])
    w_mat = w.to_matrix()
    v1 = w_mat * e1
    v2 = w_mat * e2

    # 处理 v1 = w(e1)
    if v1[0] != 0:
        sigma_1 = 1
        eps1 = 0 if v1[0] == 1 else 1
    else:
        sigma_1 = 2
        eps2 = 0 if v1[1] == 1 else 1

    # 处理 v2 = w(e2)
    if v2[0] != 0:
        sigma_2 = 1
        eps1 = 0 if v2[0] == 1 else 1
    else:
        sigma_2 = 2
        eps2 = 0 if v2[1] == 1 else 1

    sigma = S2([sigma_1, sigma_2])
    epsilon = Z2((eps1, eps2))
    return (epsilon, sigma)


print("🔹 W(B₂) → G 映射:")
for w in W:
    g = b2_to_g(w)
    print(f"{w} ↦ {g}")

"""
# 重新运行同构验证
print("✅ 重新验证同构性（使用修正后的映射）...")

"""

is_homomorphism = True
for w1 in W:
    for w2 in W:
        w_product = w1 * w2
        g_expected = b2_to_g(w_product)

        g1 = b2_to_g(w1)
        g2 = b2_to_g(w2)
        g_computed = G.mul(g1, g2)

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
定义W(B_2)→G的同构映射的逆映射
"""

def g_to_b2(g_elem):
    """
    将 G 中元素 (epsilon, sigma) 映射回 W(B2)
    构造矩阵：D * P，其中 D 是符号对角阵，P 是置换矩阵
    """
    epsilon, sigma = g_elem
    eps_list = epsilon.list()
    # 符号矩阵 D
    D = diagonal_matrix([1 if e == 0 else -1 for e in eps_list])
    # 排列矩阵 P
    if sigma == S2.identity():
        P = matrix([[1, 0], [0, 1]])
    else:
        P = matrix([[0, 1], [1, 0]])
    full_mat = D * P
    # 在 W 中查找对应元素
    for w in W:
        if w.to_matrix() == full_mat:
            return w
    raise ValueError(f"未找到匹配的 W(B2) 元素: {full_mat}")


"""
检查双射
""" 
W_list = list(W)
G_list = G.elements

image_of_W = [b2_to_g(w) for w in W_list]
preimage_of_G = [g_to_b2(g) for g in G_list]

print("✅ 双射验证:")
print(f"  |W| = {len(W_list)}, |G| = {len(G_list)}")
print(f"  W → G 像集大小: {len(set(image_of_W))}")
print(f"  G → W 像集大小: {len(set(preimage_of_G))}")

if set(image_of_W) == set(G_list) and len(W_list) == len(G_list):
    print("✅ 映射是双射！")
else:
    print("❌ 映射不是双射！")

"""
验证同构：保持群运算
"""

print("✅ 开始验证同构性（保持乘法）...")

is_homomorphism = True
for w1 in W:
    for w2 in W:
        # W 中乘积
        w_product = w1 * w2
        g_expected = b2_to_g(w_product)

        # G 中乘积
        g1 = b2_to_g(w1)
        g2 = b2_to_g(w2)
        g_computed = G.mul(g1, g2)

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
