'''
Status
999 inited； 1 error ；0 finished;2 running
'''
import json
import os,sys
from optparse import OptionParser
import pymongo
from collections import OrderedDict
import copy

def getOption():
    parser=OptionParser()
    parser.add_option('-j','--json',dest='json',help='json configuration')
    return parser.parse_args()

## 遍历config
def Deep_Generate(config,wk,sample,projectobj):
    if config.get('Path',False):
        config['Input'] = wk+"/"+sample
        config['Output'] = wk+"/"+sample
        config['Status']=999
        step = wk.split('/')[-1]
        config['Step'] = step
        config['Sample'] = sample
        if config.get('Dependence',False):
            try:
                # 这里需要改成列表以满足多个依赖关系
                newdepend=[]
                for dependence in config['Dependence']:
#                    print(sample,step,' depend is ',dependence)
                    newdepend.append(projectobj.find_one({'Step':dependence,'Sample':sample})['_id'])
                config['Dependence']=newdepend
            except:
                print(sample,step,'cannot found dependence')
                print(config['Dependence'])
                print('please note your pipeline sequence')
                sys.exit(1)
#        print(config)
        if print(projectobj.find_one({'Step':step,'Sample':sample})):
            projectobj.update({'Step':step,'Sample':sample},{'$set':config})
        else:
            projectobj.insert(config)
    else:
        for key in config.keys():
            Deep_Generate(config[key],'/'.join([wk,key]),sample,projectobj)


if __name__=='__main__':
    opt,arg=getOption()
    if opt.json:
        with open(opt.json, 'r')as f:
            config = json.load(f)
        print('open ',opt.json)
    else:
        print('please Input json file')
        sys.exit(1)
    # 生成工作目录（不存在则自动创建）
    wk = config['project']['workspace']
    newconfig = OrderedDict()
    for key,value in config.items():
        newconfig[key]=value
    if not os.path.exists(wk):
        print(wk,os.path.exists(wk))
        try:
            os.mkdir(wk)
        except:
            print('is %s sort of absolute path'%wk)
            print('or 请确认你的权限')

    client = pymongo.MongoClient(host='localhost')
    db = client.example
    projects = db['projects']
    samples = config['sample'].keys()
    if projects.find_one({"Name" : config["project"]["projectname"]}):
        projectid = projects.update({'Name': config['project']['projectname']},{'$set': {'Status': 999}})
    else:
        projectid = projects.insert({'Name':config['project']['projectname'],'Status': 999})
    process = db['process']
    for sample in samples:
        config=copy.deepcopy(newconfig)
        projectobj = process[config['project']['projectname']]
        Deep_Generate(config['process'],wk,sample,projectobj)