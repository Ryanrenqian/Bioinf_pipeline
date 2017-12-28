import json
"""
该模型为层次模型，即每层任务全部跑完时即可运行下一层的任务
"""


def model():
    tem={'project':{}}
    tem['project']['name']='test'
    tem['project']['workspace']='example'
    tem['samples']={}
    tem['process']={'child':['single','group'],'single':{}}
    # alignment layer
    Layer1=['star','subread','bwa']
    Layer2=['stringtie','starfusion','tophat','gatk']
    tem['process']['single']={'child':['Layer1,Layer2']}
    tem['process']['single']['Layer1']={'child':Layer1}
    tem['process']['single']['Layer2']={'child':Layer2}
    for i in Layer1:
        tem['process']['single']['Layer1'][i]={
            'param':None}
    for j in Layer2:
        tem['process']['single']['Layer2'][j]={
            'param':None}
    pairs={}
    tem['process']['group']={'child':['Layer3'],'pairs':pairs}
    Layer3=['DEGs','Cluster']
    tem['process']['group']['Layer3']={'child':pairs}
    for i in Layer3:
        tem['process']['group']['Layer3'][i]={
            'param': None}
    return tem

import os,re
def main(datapath,output,workspace,suffix='fq.gz',pattern='(\w+)_\d.fq.gz',template=None):
    output=os.path.abspath(output)
    if template:
        print('loading JSON')
        tem = json.load(template)
    else:
        print('Generating model')
        tem = model()
    tem['project']['workspace']=os.path.abspath(workspace)
    print('Search files')
    for root,d,files in os.walk(datapath):
        for file in files:
            if file.endswith(suffix):
               sample=re.search(pattern,file).group(1)
               print(sample)
               if sample==None:
                   print('%s have irregular name, please change its name, \
                   or change pattern and using new json again'%file)
               else:
                    tem['samples'].setdefault(sample,[]).append(os.path.join(os.path.abspath(root),file))

    with open('%s/samples.txt'%output,'w')as f:
        for sample in tem['samples']:
            f.write('%s\n'%sample)
    with open('%s/config.json'%output,'w') as f:
        json.dump(tem,f,indent='\t')

main(datapath='../example',output='../example',workspace='../example')
