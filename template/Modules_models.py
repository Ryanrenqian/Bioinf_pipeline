import json
module={}
step=['qc','alignment','BQSR','HLA_typing','variant','Peptide Selection']
for i in step:
    module[i]='sh in %s'%i
output='/Users/ryan/PycharmProjects/Bioinformatics/example/test'
with open('%s/module.json'%output,'w') as f:
    json.dump(module,f,indent='\t')