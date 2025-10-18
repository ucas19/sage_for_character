
"""
为避免 SemidirectProduct 的兼容性问题，我们手动构造元素为元组 (eps, sigma)，并定义乘法。
"""
class SemidirectProductGroup:
    def __init__(self, A, H, action):
        self.A = A
        self.H = H
        self.action = action
        self.elements = [(a, h) for a in A for h in H]
    
    def mul(self, x, y):
        a, h = x
        b, k = y
        # (a,h)(b,k) = (a * h.b, h*k)
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

