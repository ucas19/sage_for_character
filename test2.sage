from typing import Counter
#from functions import show_steps
from weyl_group_Bn import Weyl_Group_Bn
from sage.groups.perm_gps.permgroup_named import SymmetricGroup
from sage.rings.rational_field import QQ
from lowest_module import Lowest_Module
from integer_com import is_nonnegative_integer_combination_simple
from sage_integer_com import is_nonnegative_integer_combination_sage
#from functions import *
from Mu_with_message import *
from functions_file import read_rational_vectors, read_vectors_from_file
#load("functions.sage")
def check_arrays(A, B, n, m):
    def remove_matches(front, back):
        # front, back 是列表
        front_ctr = Counter(front)
        back_ctr = Counter(back)
        removed_count = 0
        
        # 遍历前段的元素（按值，但考虑重复）
        # 为了避免修改迭代中的字典，我们复制键的列表
        for x in list(front_ctr.keys()):
            abs_x = abs(x)
            # 在后段找绝对值相同的元素
            # 需要找后段中绝对值等于abs_x的任意一个元素（比如y，|y|==abs_x）
            # 但可能有多个不同符号的，我们只关心绝对值
            # 所以需要遍历后段键找匹配绝对值的
            match_found = None
            for y in list(back_ctr.keys()):
                if abs(y) == abs_x:
                    match_found = y
                    break
            if match_found is not None:
                # 能匹配，删掉一对
                min_pair = min(front_ctr[x], back_ctr[match_found])
                front_ctr[x] -= min_pair
                back_ctr[match_found] -= min_pair
                removed_count += 2 * min_pair
                if front_ctr[x] == 0:
                    del front_ctr[x]
                if back_ctr[match_found] == 0:
                    del back_ctr[match_found]
        return front_ctr, back_ctr, removed_count

    # 对A处理
    front_A = A[:n]
    back_A = A[n:]
    front_A_ctr_rem, back_A_ctr_rem, removed_A = remove_matches(front_A, back_A)
    
    # 对B处理
    front_B = B[:n]
    back_B = B[n:]
    front_B_ctr_rem, back_B_ctr_rem, removed_B = remove_matches(front_B, back_B)
    
    if removed_A != removed_B:
        return False
    
    # 比较剩余部分（绝对值多重集合）
    def abs_multiset(ctr):
        # 将计数器中的键取绝对值，并展开成多重集合列表（其实用Counter合并绝对值相同的键）
        abs_ctr = Counter()
        for k, v in ctr.items():
            abs_ctr[abs(k)] += v
        return abs_ctr
    
    abs_front_A = abs_multiset(front_A_ctr_rem)
    abs_back_A = abs_multiset(back_A_ctr_rem)
    abs_front_B = abs_multiset(front_B_ctr_rem)
    abs_back_B = abs_multiset(back_B_ctr_rem)
    
    if abs_front_A == abs_front_B and abs_back_A == abs_back_B:
        return True
    return False




if __name__ == "__main__":
    def remove_matches(front, back):
        # front, back 是列表
        removed_count = 0
        front_tem = front[:]
        print(front_tem)
        
        
        for x in front_tem:
            print(x)
        print("-----------") 
        for x in front_tem:
            if x in back:
                front.remove(x)
                back.remove(x)
                removed_count += 1
            elif -x in back:
                front.remove(x)
                back.remove(-x)
                removed_count += 1
            else:
                continue
        
        front_ctr = Counter(front)
        back_ctr = Counter(back)
        return front_ctr, back_ctr, removed_count


    a,b,c = remove_matches([-1,-1,1,1,1],[1,1,1,-1,-1])
    print(a)
    print(b)
    print(c)
