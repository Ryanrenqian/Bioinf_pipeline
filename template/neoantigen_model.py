import json
import sys



process={'alignment':{},'variant':{},'somatic':{},'neoantigen':{}}
# alignment part
alignment={}
alignment['STAR']={'Path':'/Path/to/star','Param':'params','Input':'.fq'}
alignment['STAR2']={'Path':'/Path/to/star','Param':'params','Input':'fq'}
alignment['BWA']={'Path':'/Path/to/bwa','Param':'params','Input':'fq'}
process['alignment']=alignment

#variant part
variant={}
variant['GATK']={'Path':'/Path/to/GATK','Param':'params','Input':'bam','Dependence':['STAR']}
process['variant']=variant

# somatic
somatic={}
somatic['varscan']={'Path':'/Path/to/varscan','Param':'params','Dependence':['GATK','STAR'],'Input':'vcf'}
somatic['strekla']={'Path':'/Path/to/strekla','Param':'params','Dependence':['GATK'],'Input':'vcf'}
process['somatic']=somatic

# purity and clonal


# neoantigen
neoantigen={}



# project part
project={}
project['projectname']='example'
project['workspace']='/Users/ryan/PycharmProjects/Bioinformatics/example/neoantigen'
project['global']=None

# sample
sample={}
sample['chenmeiyun_N']={'Step':'GATK','data':['/Users/ryan/PycharmProjects/Bioinformatics/example/vatian/']}
sample['chenmeiyun_T']={'Step':'GATK','data':['/Users/ryan/PycharmProjects/Bioinformatics/example/vatian/']}

# group
group={}
group['groups']={'group1'}

#config part
config={}
config['project']=project
config['process']=process
config['sample']=sample
# generate namespace
def generateNamespace(process,namespace=[]):
    for job in process.keys():
        if process[job].get('Path',False):
            namespace.append(job)
            break
        else:
            generateNamespace(process[job],namespace)
    return namespace
namespace=generateNamespace(process)

# check namespace
if len(set(namespace)) != len(namespace):
    print('please check your job name! overlapped namespace')
    sys.exit(1)

#def generateUid(project,namespace):
#    for job in process.keys():
#        if process[job]['Path']:
#            process[job]['uid']=uuid.uuid3(namespace,job)
#        else:
#            generateUid(project, namespace)
#    return project
#project=generateUid(project,namespace)

with open('../example/neoantigen_config.json','w')  as f:
    json.dump(config,f,indent='\t')