# Sage 示例（概念性）
L = LieSuperalgebra("osp", [3,6])
V = L.highest_weight_module([0,1,0,0])  # [a; b1,b2,b3]
print(V.dimension())  # 输出 48
print(V.weight_multiplicities())
