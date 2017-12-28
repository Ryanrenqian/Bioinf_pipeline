import pymongo
client = pymongo.MongoClient()
db = client.example
projectdb = db.projects
# remove process
processdb = db.process
processdb['example'].delete_many({'Param':'params'})
for i in processdb['example'].find():
    print(i)