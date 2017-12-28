import random
import string
import os
os.system('mkdir -p data')
for i in range(10):
    name="".join(random.sample(string.ascii_letters+string.digits,8))
    with open('data/%s_1.fq.gz'%name,'w')as f:
        f.write('just a %s test'%name)
    with open('data/%s_2.fq.gz'%name,'w')as f:
        f.write('just a %s test'%name)
