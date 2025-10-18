
"""
为避免 SemidirectProduct 的兼容性问题，我们手动构造元素为元组 (eps, sigma)，并定义乘法。
"""
class SemidirectProductGroup:
    def __init__(self, A, H):
        self.A = A
        self.H = H
        #self.action = action
        self.elements = [(a, h) for a in A for h in H]
    
    
    def mul(self, el1, el2):
        epsilon1, sigma1 = el1
        epsilon2, sigma2 = el2
#        print(el1,el2)
        # 计算 σ₁(ε₂)
        sigma1_inv = sigma1.inverse()
        eps2_list = list(epsilon2.list())
        twisted_eps2_list = [eps2_list[sigma1_inv(i+1)-1] for i in range(len(eps2_list))]
        twisted_eps2 = self.A(twisted_eps2_list)
        
        # 计算 ε₁ + σ₁(ε₂)
        eps1_list = list(epsilon1.list())
        twisted_eps2_list = list(twisted_eps2.list())
        new_epsilon = self.A([(eps1_list[i] + twisted_eps2_list[i]) % 2 for i in range(len(eps1_list))])
        
        # 计算 σ₁σ₂
        new_sigma = sigma2 * sigma1
 #       print(f"乘积{new_sigma},{sigma1},{sigma2}")
        
        return (new_epsilon, new_sigma)
    def mul2(self, x, y):
        a, h = x
        b, k = y
        # (a,h)(b,k) = (a * h.b, h*k)
        print(f"{h} {b}")
        hb = self.action(h, b)
        new_a = a * hb
        new_h = h * k
        return (new_a, new_h)
    
    def inv(self, x):
        a, h = x
        # (a,h)⁻¹ = (h⁻¹.a⁻¹, h⁻¹)
        h_inv = h.inverse()
        a_inv = a.inverse()
        return (self.action(h_inv, a_inv), h_inv)

