#!/usr/bin/python
"""
   makes a combined new kaldi model (gmm) from the cluster map 

usage:
  convert_cluster_to_activation_map.py <clusterfile> <activation_map>
e.g.
  convert_cluster_to_activation_map.py clusBP_radTo4_wsj_4674to935_8.txt tmp/activationmap.ccnc.txt
"""

import sys,argparse

# assume dimensions

p=argparse.ArgumentParser()
p.add_argument('--DIM',default=40,type=int,help="dimension of mixtures");
p.add_argument("--NUMMIX",default=4,type=int)
p.add_argument('CLUSTERFILE');
p.add_argument('MODELFILE');
p.add_argument('OUTFILE');

args=p.parse_args(sys.argv[1:])

CLUSTERFILE=args.CLUSTERFILE
MODELFILE=args.MODELFILE
OUTFILE=args.OUTFILE
DIM=args.DIM
NUMMIX=args.NUMMIX

def die(info):
    print info    
    sys.exit(-1)

def read_cluster_data(fin,mix=4,dim=DIM):
    data=[]
    for m in range(mix):
        v=[]
        # parse the info line
        for k in range(dim):
            line=fin.readline()
            if line.startswith('<mixCount>'):
                # discard additional mixture lines
                assert(k==0)
                line=fin.readline()
            #print fin.line_number()
            #print line
            v.append(float(line.strip()))
        data.append(v)
    return data

def read_cluster_num_and_data(fin,mix=4,dim=DIM):
    "returns cluster data as a list of lists"
    line=fin.readline()
    (clusterTerm,num,mixcntTerm,mixcnt)=line.strip().split()
    if clusterTerm != '<clus_num>' or mixCount != '<mixCount>':
        die("invalid cluster at line: "+line)
    return read_cluster_data(fin,mix,dim)

class TextFH():
    def __init__(self,fh):
        self.lc=0
        self.fh=fh
        self.buffer=[]

    def readline(self): 
        self.lc=self.lc+1
        if len(self.buffer)>0:
            ul=self.buffer[-1]
            self.buffer=self.buffer[:-1]
            return ul
        return self.fh.readline()

    def unreadline(self,line): 
        self.lc=self.lc-1
        self.buffer.append(line)

    def line_number(self): 
        return self.lc
    
    def close(self):
        self.fh.close()
    
def load_clusfile(clusfile,nummix=4):
    "loads a cluster file, returns an array of tuples, (weight,means,vars)"
    fin=TextFH(open(clusfile,'rt'))
    done=False
    num_clusters=0
    lineno=0
    weights=[]
    means=[]
    vars=[]
    clustermap=[]
    
    while not done:
        lineno=lineno+1
        line=fin.readline()
        if line=='': done=True; continue
        line=line.strip()
        tag=line.split()[0]
        if tag in ['<weig>','<mean>','<vari>','<gconst>','<clus_map>']:
            section=tag
        elif tag=='<clus_num>':
            if section =='<clus_map>':
                cluster = []
                line=fin.readline()
                while line[0] != '<':
                    cluster.append(int(line))
                    line=fin.readline()
                fin.unreadline(line)
                clustermap.append(cluster)
                num_clusters=num_clusters+1 
            else:
                if section =='<weig>':
                    vdata=read_cluster_data(fin,nummix,1)
                    weights.append(map(lambda(x): x[0],vdata))
                elif section =='<gconst>':
                    vdata=read_cluster_data(fin,nummix,1)
                elif section =='<mean>':
                    vdata=read_cluster_data(fin,nummix)
                    means.append(vdata)
                elif section =='<vari>':
                    vdata=read_cluster_data(fin,nummix)
                    vars.append(vdata)

        else:
            die(" unmatched line on %i" % fin.line_number())
    
    return (clustermap,weights,means,vars)

def print_kaldi_gmms(weights,means,vars,fout=sys.stdout,dim=DIM):
    print >>fout, "<DIMENSION> %i <NUMPDFS> %i " % (dim,len(weights)),
    for i in range(len(weights)):
        wt=weights[i]
        m=means[i]
        v=vars[i]
        print >>fout, "<DiagGMM>"
        print >>fout, "<WEIGHTS> ", '[ %s ]' %  ' '.join(map(lambda(x): " %.5f " %x,wt))
        print >>fout, "<MEANS_INVVARS> ["
        for i in range(len(m)):
            for k in range(len(m[i])):
                x=m[i][k]/v[i][k]
                print >>fout, "%.5f " % x,
            if i==len(m)-1: print >>fout, ' ]'
            else: print >>fout,''
        print >>fout, "<INV_VARS> [ "
        for i in range(len(m)):
            for k in range(len(m[i])):
                x=1/v[i][k]
                print >>fout, "%.5f " % x,
            if i==len(m)-1: print >>fout, ' ]'
            else: print >>fout, ''
        print >>fout, "</DiagGMM>"

def copy_transition_model(infn,out):
    fin=open (infn,'rt')
    toggle=False
    for line in fin:
        if line.find("TransitionModel") !=-1:
            toggle=not toggle
        if toggle: print >>out,line
    print >>out,"</TransitionModel>"
    fin.close()

#
clusmap,weights,means,vars=load_clusfile(CLUSTERFILE,NUMMIX)

# 
fout=open(OUTFILE,'wt')
copy_transition_model(MODELFILE,fout);
print_kaldi_gmms(weights,means,vars,fout,DIM)
fout.close()
