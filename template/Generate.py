from optparse import OptionParser
def getOption():
    parser=OptionParser()
    parser.add_option('-p','--path',dest='path')
    parser.add_option('-d','--dict',dest='dict')
    parser.add_option()