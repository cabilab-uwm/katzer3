"""Dissimilarity measure"""

" item similarity between two runs that belong to the same design"

__docformat__ = 'restructuredtext'

from numpy import *
from numpy.random import randint
from scipy.stats.stats import *
from mvpa2.measures.base import Measure
from mvpa2.measures import rsa

class run_dsm(Measure):

    def __init__(self, metric, output):
        Measure.__init__(self)

        self.metric = metric
        self.dsm = []
        self.output = output

    def __call__(self, dataset):

        self.dsm = rsa.PDist(\
                        square=True,\
                        pairwise_metric=self.metric,\
                        center_data=False)

        dsmat = self.dsm(dataset).samples      
        
        sameitem = []
        samecat = []
        diffcat = []        
        
        for x in range(len(dataset.targets)):
            for y in range(x+1, len(dataset.targets)):
                if dataset.chunks[x] == dataset.chunks[y]:
                    continue
                else:
                    stx = dataset.targets[x]
                    sty = dataset.targets[y]
                    dstmp = 1-dsmat[x,y]
                    if stx==sty:
                        if dataset.sa.pic[x] == dataset.sa.pic[y]:
                            sameitem.append(dstmp)                            
                        else:
                            samecat.append(dstmp)
                    
                    elif stx!=sty:
                            diffcat.append(dstmp)

           
        sameitem = mean(arctanh(array(sameitem)))
        samecat = mean(arctanh(array(samecat)))
        diffcat = mean(arctanh(array(diffcat)))   
          
        
        obsmns = []
        obsmns.append(sameitem) 
        obsmns.append(samecat) 
        obsmns.append(diffcat) 
        
        return obsmns
