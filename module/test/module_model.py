import subprocess
class module:
    def __init__(self,wkdir,env,bin):
        self.env=env
        self.wkdir=wkdir
        self.bin=bin
    def run(self,*keys,input,output,param):
        command=subprocess.run([*keys],stdout=subprocess.PIPE)
        return command
test=module(wkdir='/Users/ryan/PycharmProjects/Bioinformatics/example/test',env='',bin='bash')
result=test.run(test.bin,'/Users/ryan/PycharmProjects/Bioinformatics/module/test/test.sh','input',test.wkdir,'params')
print(result)
