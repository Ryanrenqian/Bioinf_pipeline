import multiprocessing
import pymongo
import os,time
'''
projects  = {project: name}
jobs = {projectname , jobs}
'''

def submit(processes):
    def run(processobj):   # test run
#        print(processobj)
        processes.update(processobj, {'$set': {'Status': 0}})
    for processobj in processes.find({'Status':999}):
        if processobj.get('dependence'):
            try:
                if processes.find_one({'_id':processobj['dependence']})['Status']==0:
                    processes.update(processobj,{'$set':{'Status':2}})
                    run(processobj)
                    print(processobj['Name'],'has beed submitted!')
            except:
                print('Please seek _id',processes.find_one({'_id':processobj['dependence']}),' in database: ',processes)
        else:
            run(processobj)
            print(processobj['Name'],'has beed submitted!')
            processobj['Status']=2

def autoSubmit(projectdb,processdb):
    while True:
        for projectobj in projectdb.find():
            if projectobj['Status']  != 0 :
                submit(processdb[projectobj['Name']])
                print('Project:',projectobj['Name'], 'is submited!')
                projectobj['Status']= 2
        time.sleep(60)

def check(processes):
    for processobj in processes.find({'Status':2}):
        filename=processobj['output']+'/'+'sign'
        if os.path.exists(filename):
            with open(filename,'r')as f:
                processes.update(processobj, {'$set': {'Status': int(f.readline().strip())}})
    if len([i for i in processes.find({'Status':0})])==len([i for i in processes.find()]):
        return 0
    elif processes.find({'Status':1}):
        return 1


def checkStatus(projectdb,processdb):
    while True:
        for projectobj in projectdb.find():
            if projectobj['Status'] != 0:
                processdb.update(projectobj,{'$set':{'Status':check(processdb[projectobj['Name']])}})



if __name__=='__main__':
    client = pymongo.MongoClient()
    db = client.pipeline
    projectdb = db.projects
    processdb = db.process
    p1=multiprocessing.Process(target=checkStatus,args=(projectdb, processdb,))
    p1.start()
    p2=multiprocessing.Process(target=autoSubmit,args=(projectdb, processdb,))
    p2.start()