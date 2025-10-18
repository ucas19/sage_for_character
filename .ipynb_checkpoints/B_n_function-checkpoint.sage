# 设置李代数类型和秩
n = 4
R = RootSystem(['B', n])
W = WeylGroup(['B', n], prefix="s")  # Weyl群，生成元命名为 s1, s2, ...
L = R.weight_lattice()
fund_weights = L.fundamental_weights()

# 给定一个支配整权 lambda（用基本权的系数表示）
# 例如：lambda = 2*ϖ1 + 0*ϖ2 + 3*ϖ3 + 0*ϖ4
coeffs = [2, 0, 3, 0]  # 必须是非负整数（支配整权）
lmbda = coeffs

print("λ =", lmbda)

# 获取单反射生成元
generators = W.simple_reflections()  # generators[i] 对应第 i 个单反射
