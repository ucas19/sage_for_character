# 检查 SageMath 版本和方法可用性
import sage

print(f"SageMath 版本: {sage.version.version}")

W = WeylGroup(['A', 3], prefix='s')

# 查看 Weyl 群的所有方法
print("\nWeyl 群方法:")
for method in dir(W):
    if 'subgroup' in method.lower() or 'parabolic' in method.lower() or 'coset' in method.lower() or 'coxeter' in method.lower():
        print(f"  {method}")

# 查看 Coxeter 群的方法
#C = W.coxeter_group()
#print("\nCoxeter 群方法:")
#for method in dir(C):
#    if 'subgroup' in method.lower() or 'parabolic' in method.lower() or 'coset' in method.lower():
#        print(f"  {method}")
