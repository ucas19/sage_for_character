from sage.groups.perm_gps.permgroup_named import SymmetricGroup
from sage.groups.perm_gps.permgroup import PermutationGroup
from sage.groups.abelian_gps.abelian_group import AbelianGroup
from sage.combinat.root_system.weyl_group import WeylGroup
from sage.matrix.constructor import diagonal_matrix, identity_matrix
from sage.modules.free_module_element import vector
from SemidirectProductGroup import SemidirectProductGroup
from sage.combinat.root_system.cartan_type import CartanType
#from sage.groups.artin import CoxeterGroup
from sage.rings.integer_ring import ZZ
from sage.rings.rational_field import QQ
from sage.all import CoxeterGroup, AA
from collections import Counter
from sage.all import zero_vector


class Mu_With_Message:

    def __init__(self,type, result):
        #type是得到的方式，0代表就是本身，1代表从第一二种方法得到的，3代表从第三种方法得到的，5代表从5，6中方法得到的
        # step_set代表步数，就是反射的根的集合
        # plus_roots代表
        self.type = type
        self.step_set = []
        self.plus_roots = []
        self.result = result
