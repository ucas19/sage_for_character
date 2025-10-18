# 创建有理数向量
v = vector(QQ, [1/2, 1/3, 355/113, 22/7])
print("原始向量:", v)
print("类型:", type(v))

# 转换为列表
v_list = v.list()
print("转换后的列表:", v_list)
print("列表元素类型:", [type(x) for x in v_list])

# 验证精度
print("精度验证:")
for i, elem in enumerate(v_list):
    print(f"元素 {i}: {elem} (类型: {type(elem)})")
    
# 重新转换为向量
v_back = vector(QQ, v_list)
print("重新转换的向量:", v_back)
print("是否相等:", v == v_back)
