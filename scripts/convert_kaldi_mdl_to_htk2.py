#!/usr/bin/python
"""
   Converts a final.mdl.txt file in text format to something similar to HMMDEFs for clustering

usage: convert_kaldi_mdl_to_htk2.py <MODEL> <OUTPUT>
    where MODEL is a text formatted version of Kaldi's final.mdl (only GMMs)
      and OUTPUT is something that looks like HTK's HMMDEFS (used by He Di's cluster code)

 e.g. convert_kaldi_mdl_to_htk2.py models/*/final.mdl.txt data/wsj_tri2b_hmmdefs_part.txt
"""

import sys


if len(sys.argv)<2:
    print __doc__
    sys.exit(-1)

IN=sys.argv[1]
OUT=sys.argv[2]

def read_matrix(fin):
    finished=False
    m=[]
    while not finished:
        line=fin.readline()
        if line.find(']')!=-1: finished=True
        v=map(lambda(x): float(x),line.replace(']','').strip().split())
        m.append(v)
    return m;
        

def produce_gmm(N,wt,means_invvars,invvars,fout=sys.stdout):
    nummixes=len(wt)
    dim=len(means_invvars[0])
    print >>fout,'~s "senone_%i"' % N
    print >>fout,"<NUMMIXES> %i" % nummixes
    for k in range(nummixes):
        print >>fout,"<MIXTURE> %i %f" % (nummixes,wt[k])
        m_invvar=means_invvars[k]
        invvar=invvars[k]

        vars=map(lambda(x): 1.0/float(x),invvar)
        def calc(minvv,invv): return float(minvv)/float(invv)
        means=map(calc,m_invvar,invvar)

        print >>fout,' '.join(map(lambda(x): "%f" % x,means))

        print >>fout,"<MEAN> %s" % ' '.join(map(lambda(x): "%f" %x,means))
        print >>fout,"<VARIANCE> %s" % ' '.join(map(lambda(x): "%f" %x,vars))

wts=None
means_invvars=None
invvars=None
N=0
done=False
fin=open(IN,'rt')
fout=open(OUT,'wt')
while not done:
    line=fin.readline()
    if line =='': done=True; continue
    tag=line.strip().split()[0]
    if tag[0]=='<' and tag[-1]=='>':
        tag=tag[1:-1].upper()
    else:
        continue
    if tag=='WEIGHTS':
        wts = map(lambda(x): float(x),filter(lambda(x): x!='[' and x!=']',
            line.strip().split()[1:]))
    if tag=='MEANS_INVVARS':
        means_invvars=read_matrix(fin)
    if tag=='INV_VARS':
        invvars=read_matrix(fin)

    if wts != None and means_invvars != None and invvars != None:
        N=N+1
        produce_gmm(N,wts,means_invvars,invvars,fout)
        wts=None; means_invvars=None; invvars=None
fin.close()
fout.close()
