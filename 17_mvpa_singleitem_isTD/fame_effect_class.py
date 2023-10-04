#!/usr/bin/python



from numpy import *
import pylab as plt
import errno
from scipy.io import *
from random import sample
import os
import sys
import nibabel

from mvpa2.base.node import *
from mvpa2.datasets.mri import *
#from mvpa2.clfs.knn import *
from mvpa2.clfs.meta import *
from mvpa2.clfs.svm import *
from mvpa2.clfs.smlr import *
#from mvpa2.clfs.plr import *
from mvpa2.clfs.stats import *
from mvpa2.featsel.base import *
from mvpa2.featsel.helpers import *
from mvpa2.generators.permutation import *
from mvpa2.generators.partition import *
from mvpa2.generators.base import *
#from mvpa2.mappers.detrend import *
from mvpa2.mappers.zscore import *
from mvpa2.mappers.fx import *
from mvpa2.measures.base import *
from mvpa2.measures import *
#from mvpa2.measures.searchlight import *
from mvpa2.measures.anova import *
from mvpa2.misc.stats import *

# Annoying path code to deal with different home directories
absolute_path = os.getcwd()
basedir = os.path.realpath(os.path.join(absolute_path,'..','..'))

# Starting info
sbjs = ('301','302','304','305','309','307')

durs = (1,4)
allruns = (1,2,3,4,5,6)
masks = ('b_lo','b_pfus','b_phc','b_it','b_ahip','b_phip','b_hip') # 'b_ahip','b_phip','b_mofc','b_ifg','b_mtg','b_supar', 'b_ipar','b_angular','b_precuneus','b_striatum','b_erc'
alg = ('svm') # 'svm' or 'smlr' classifier algorithm
featsel = True    # use feature selection
featseln = 1000   # number of features selected
saveres = True   # save test prediction results
decoded = ('ismanmade') #label for what's decoded?
trialsets = (1,0)
resultdir = os.path.realpath(os.path.join(absolute_path,'..','mvpa_results/17_singleitem_isTD/00_fame_effect'))
print(resultdir)

def mkdir_p(resultdir):
    try:
        os.makedirs(resultdir)
    except OSError as exc: 
        if exc.errno == errno.EEXIST and os.path.isdir(resultdir):
            pass
        
mkdir_p(resultdir)

            
for thisdur in durs:
    print('Starting Duration: '+str(thisdur))
    for thistrialset in trialsets:
        print('...starting to decode: '+str(thistrialset))
        for mask in masks:
            print('......starting ROI: '+mask)

            if thistrialset == 1:
                accresultstr = decoded+'_famous_dur'+str(thisdur)+'_'+mask
            elif thistrialset == 0:
                accresultstr = decoded+'_nonfamous_dur'+str(thisdur)+'_'+mask

            allaccbyrun = [] # accuracy for classifying across all runs
            pnlaccbyrun = [] # accuracy for classifying using only perception w/o labels runs
            placcbyrun = [] # accuracy for classifying using only perception w/labels runs 
            recaccbyrun = [] # accuracy for classifying using only recall runs
            pnltrain_pltest_acc = [] # accuracy for training on perception w/o labels, test on perception w/labels
            pltrain_pnltest_acc = [] # accuracy for training on perception w/labels, test on perception w/o labels
            allptrain_rectest_acc = [] # accuracy for training on all perception, testing on recall
            rectrain_allptest_acc = [] # accuracy for training on recall, testing on all perception
            nlptrain_rectest_acc = [] # accuracy for training on perception w/o labels, testing on recall
            lptrain_rectest_acc = [] # accuracy for training on perception w/labels, testing on recall
            rectrain_nlptest_acc = [] # accuracy for training on recall, testing on perception w/o labels
            rectrain_lptest_acc = [] # accuracy for training on recall, testing on perception w/labels

            for sbj in sbjs:
                print(".........starting "+sbj)

                if thistrialset == 1:
                    evpredresultstr = 'sub-'+sbj+'_'+decoded+'_famous_dur'+str(thisdur)+'_'+mask 
                elif thistrialset == 0:
                    evpredresultstr = 'sub-'+sbj+'_'+decoded+'_nonfamous_dur'+str(thisdur)+'_'+mask        
                
                sbjdir = basedir+'/sub-'+sbj
                maskdir = sbjdir+'/anat/antsreg/masks'
                datadir = sbjdir+'/func/singleitem_isTD'
                exponsetdir = basedir+'/pattern_info/singleitem'      
                
                ## read in data           
                betan,runs,tasks,picidx,isfamous,ismanmade = loadtxt(exponsetdir+'/'+sbj+'/si_pattern_info.txt',unpack=1)
                betas = datadir+'/betas_all_dur'+str(thisdur)+'.nii.gz'
                expds = fmri_dataset(betas,mask=maskdir+'/'+mask+'.nii.gz')                 
                ## do classification with all runs
                expds.sa['chunks'] = runs
                expds.sa['targets'] = eval(decoded)
                expds.sa['tasks'] = tasks
                expds.sa['isfamous'] = isfamous

                expds = expds[expds.sa.isfamous == thistrialset]
                
                zscore(expds,chunks_attr='chunks')

                ## setup classifier
                if alg=='svm':
                    clf = LinearCSVMC(probability=1,enable_ca=['probabilities'])
            
                elif alg=='smlr':
                    clf = SMLR()

                if featsel:
                    tailsel = FixedNElementTailSelector(featseln,mode='select',tail='upper')
                    fsel = SensitivityBasedFeatureSelection(OneWayAnova(),tailsel)
                    fsclf = FeatureSelectionClassifier(clf,fsel)
                else:
                    fsclf = clf 

                eachrunacc = []
                eachrunev = []
                eachrunpred = []
                for thisrun in allruns:
                    train_ds = expds[expds.sa.chunks != thisrun]
                    test_ds = expds[expds.sa.chunks == thisrun]
                    fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                    fsclf.train(train_ds)
                    err = fsclf(test_ds)
                    acc = 1-mean(err.samples)
                    evidence = fsclf.ca.estimates
                    predictions = fsclf.ca.predictions  
                    eachrunacc.append(acc)
                    eachrunev.append(array(evidence).flatten())
                    eachrunpred.append(array(predictions).flatten())
                allaccbyrun.append(array(eachrunacc).flatten())
                allrunev = np.reshape(eachrunev,len(expds))      
                allrunpred = np.reshape(eachrunpred,len(expds))
        
                mkdir_p(resultdir+'/allruns_acc')
                mkdir_p(resultdir+'/allruns_evidence') 
                mkdir_p(resultdir+'/allruns_predictions')            
                savetxt(resultdir+'/allruns_evidence/'+evpredresultstr+'.txt',allrunev,fmt='%.6f')
                savetxt(resultdir+'/allruns_predictions/'+evpredresultstr+'.txt',allrunpred,fmt='%.6f')

                # perception w/o labels runs
                thisset = expds[expds.sa.tasks == 1]
                zscore(thisset,chunks_attr='chunks')

                eachrunacc = []
                eachrunev = []
                eachrunpred = []                 
                for thisrun in np.unique(thisset.sa.chunks):
                    train_ds = thisset[thisset.sa.chunks != thisrun]
                    test_ds = thisset[thisset.sa.chunks == thisrun]
                    fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                    fsclf.train(train_ds)
                    err = fsclf(test_ds)
                    acc = 1-mean(err.samples)
                    evidence = fsclf.ca.estimates
                    predictions = fsclf.ca.predictions
                    eachrunacc.append(acc)
                    eachrunev.append(array(evidence).flatten())
                    eachrunpred.append(array(predictions).flatten())
                pnlaccbyrun.append(array(eachrunacc).flatten())
                pnlrunev = np.reshape(eachrunev,len(thisset))
                pnlrunpred = np.reshape(eachrunpred,len(thisset))
         
                mkdir_p(resultdir+'/pnlruns_acc')
                mkdir_p(resultdir+'/pnlruns_evidence') 
                mkdir_p(resultdir+'/pnlruns_predictions')            
                savetxt(resultdir+'/pnlruns_evidence/'+evpredresultstr+'.txt',pnlrunev,fmt='%.6f')
                savetxt(resultdir+'/pnlruns_predictions/'+evpredresultstr+'.txt',pnlrunpred,fmt='%.6f')
    
                # perception w labels runs
                thisset = expds[expds.sa.tasks == 2]
                zscore(thisset,chunks_attr='chunks')

                eachrunacc = []
                eachrunev = []
                eachrunpred = []                 
                for thisrun in np.unique(thisset.sa.chunks):
                    train_ds = thisset[thisset.sa.chunks != thisrun]
                    test_ds = thisset[thisset.sa.chunks == thisrun]
                    fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                    fsclf.train(train_ds)
                    err = fsclf(test_ds)
                    acc = 1-mean(err.samples)
                    evidence = fsclf.ca.estimates
                    predictions = fsclf.ca.predictions
                    eachrunacc.append(acc)
                    eachrunev.append(array(evidence).flatten())
                    eachrunpred.append(array(predictions).flatten())
        
                placcbyrun.append(array(eachrunacc).flatten())
                plrunev = np.reshape(eachrunev,len(thisset))
                plrunpred = np.reshape(eachrunpred,len(thisset))
         
                mkdir_p(resultdir+'/plruns_acc')
                mkdir_p(resultdir+'/plruns_evidence') 
                mkdir_p(resultdir+'/plruns_predictions')            
                savetxt(resultdir+'/plruns_evidence/'+evpredresultstr+'.txt',plrunev,fmt='%.6f')
                savetxt(resultdir+'/plruns_predictions/'+evpredresultstr+'.txt',plrunpred,fmt='%.6f')
   
                # recall runs
                thisset = expds[expds.sa.tasks == 3]
                zscore(thisset,chunks_attr='chunks')

                eachrunacc = []
                eachrunev = []
                eachrunpred = []                 
                for thisrun in np.unique(thisset.sa.chunks):
                    train_ds = thisset[thisset.sa.chunks != thisrun]
                    test_ds = thisset[thisset.sa.chunks == thisrun]
                    fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                    fsclf.train(train_ds)
                    err = fsclf(test_ds)
                    acc = 1-mean(err.samples)
                    evidence = fsclf.ca.estimates
                    predictions = fsclf.ca.predictions
                    eachrunacc.append(acc)
                    eachrunev.append(array(evidence).flatten())
                    eachrunpred.append(array(predictions).flatten())
        
                recaccbyrun.append(array(eachrunacc).flatten())
                recrunev = np.reshape(eachrunev,len(thisset))
                recrunpred = np.reshape(eachrunpred,len(thisset))
         
                mkdir_p(resultdir+'/recruns_acc')
                mkdir_p(resultdir+'/recruns_evidence') 
                mkdir_p(resultdir+'/recruns_predictions')            
                savetxt(resultdir+'/recruns_evidence/'+evpredresultstr+'.txt',recrunev,fmt='%.6f')
                savetxt(resultdir+'/recruns_predictions/'+evpredresultstr+'.txt',recrunpred,fmt='%.6f') 

                # Train on no labels perception, test on labels perception
                thisset = expds[expds.sa.tasks != 3]
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 1]
                test_ds = thisset[thisset.sa.tasks == 2]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                pnltrain_pltest_acc.append(acc)
        
                mkdir_p(resultdir+'/pnltrain_pltest_acc')
                mkdir_p(resultdir+'/pnltrain_pltest_evidence') 
                mkdir_p(resultdir+'/pnltrain_pltest_predictions')            
                savetxt(resultdir+'/pnltrain_pltest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/pnltrain_pltest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

                # Train on labels perception, test on no labels perception
                thisset = expds[expds.sa.tasks != 3]
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 2]
                test_ds = thisset[thisset.sa.tasks == 1]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                pltrain_pnltest_acc.append(acc)
        
                mkdir_p(resultdir+'/pltrain_pnltest_acc')
                mkdir_p(resultdir+'/pltrain_pnltest_evidence') 
                mkdir_p(resultdir+'/pltrain_pnltest_predictions')            
                savetxt(resultdir+'/pltrain_pnltest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/pltrain_pnltest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')	

                # Train on all perception, test on recall
                thisset = expds
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks != 3]
                test_ds = thisset[thisset.sa.tasks == 3]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                allptrain_rectest_acc.append(acc)
        
                mkdir_p(resultdir+'/allptrain_rectest_acc')
                mkdir_p(resultdir+'/allptrain_rectest_evidence') 
                mkdir_p(resultdir+'/allptrain_rectest_predictions')            
                savetxt(resultdir+'/allptrain_rectest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/allptrain_rectest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

                # Train on recall, test on all perception
                thisset = expds
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 3]
                test_ds = thisset[thisset.sa.tasks != 3]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                rectrain_allptest_acc.append(acc)
        
                mkdir_p(resultdir+'/rectrain_allptest_acc')
                mkdir_p(resultdir+'/rectrain_allptest_evidence') 
                mkdir_p(resultdir+'/rectrain_allptest_predictions')            
                savetxt(resultdir+'/rectrain_allptest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/rectrain_allptest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

                # Train on no labels perception, test on recall
                thisset = expds[expds.sa.tasks != 2]
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 1]
                test_ds = thisset[thisset.sa.tasks == 3]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                nlptrain_rectest_acc.append(acc)
        
                mkdir_p(resultdir+'/nlptrain_rectest_acc')
                mkdir_p(resultdir+'/nlptrain_rectest_evidence') 
                mkdir_p(resultdir+'/nlptrain_rectest_predictions')            
                savetxt(resultdir+'/nlptrain_rectest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/nlptrain_rectest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

                # Train on labels perception, test on recall
                thisset = expds[expds.sa.tasks != 1]
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 2]
                test_ds = thisset[thisset.sa.tasks == 3]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                lptrain_rectest_acc.append(acc)
        
                mkdir_p(resultdir+'/lptrain_rectest_acc')
                mkdir_p(resultdir+'/lptrain_rectest_evidence') 
                mkdir_p(resultdir+'/lptrain_rectest_predictions')            
                savetxt(resultdir+'/lptrain_rectest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/lptrain_rectest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

                # Train on recall, test on no labels perception
                thisset = expds[expds.sa.tasks != 2]
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 3]
                test_ds = thisset[thisset.sa.tasks == 1]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                rectrain_nlptest_acc.append(acc)
        
                mkdir_p(resultdir+'/rectrain_nlptest_acc')
                mkdir_p(resultdir+'/rectrain_nlptest_evidence') 
                mkdir_p(resultdir+'/rectrain_nlptest_predictions')            
                savetxt(resultdir+'/rectrain_nlptest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/rectrain_nlptest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

                # Train on recall, test on labels perception
                thisset = expds[expds.sa.tasks != 1]
                zscore(thisset,chunks_attr='chunks')                              
                
                train_ds = thisset[thisset.sa.tasks == 3]
                test_ds = thisset[thisset.sa.tasks == 2]
                fsclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
                fsclf.train(train_ds)
                err = fsclf(test_ds)
                acc = 1-mean(err.samples)
                evidence = fsclf.ca.estimates
                predictions = fsclf.ca.predictions
        
                rectrain_lptest_acc.append(acc)
        
                mkdir_p(resultdir+'/rectrain_lptest_acc')
                mkdir_p(resultdir+'/rectrain_lptest_evidence') 
                mkdir_p(resultdir+'/rectrain_lptest_predictions')            
                savetxt(resultdir+'/rectrain_lptest_evidence/'+evpredresultstr+'.txt',evidence,fmt='%.6f')
                savetxt(resultdir+'/rectrain_lptest_predictions/'+evpredresultstr+'.txt',predictions,fmt='%.6f')

    		if saveres:
        		savetxt(resultdir+'/allruns_acc/'+accresultstr+'.txt',allaccbyrun,fmt='%.6f')
        		savetxt(resultdir+'/pnlruns_acc/'+accresultstr+'.txt',pnlaccbyrun,fmt='%.6f')
        		savetxt(resultdir+'/plruns_acc/'+accresultstr+'.txt',placcbyrun,fmt='%.6f')
        		savetxt(resultdir+'/recruns_acc/'+accresultstr+'.txt',recaccbyrun,fmt='%.6f')
        		savetxt(resultdir+'/pnltrain_pltest_acc/'+accresultstr+'.txt',pnltrain_pltest_acc,fmt='%.6f')
        		savetxt(resultdir+'/pltrain_pnltest_acc/'+accresultstr+'.txt',pltrain_pnltest_acc,fmt='%.6f')
        		savetxt(resultdir+'/allptrain_rectest_acc/'+accresultstr+'.txt',allptrain_rectest_acc,fmt='%.6f')
        		savetxt(resultdir+'/rectrain_allptest_acc/'+accresultstr+'.txt',rectrain_allptest_acc,fmt='%.6f')
        		savetxt(resultdir+'/nlptrain_rectest_acc/'+accresultstr+'.txt',nlptrain_rectest_acc,fmt='%.6f')
        		savetxt(resultdir+'/lptrain_rectest_acc/'+accresultstr+'.txt',lptrain_rectest_acc,fmt='%.6f')
        		savetxt(resultdir+'/rectrain_nlptest_acc/'+accresultstr+'.txt',rectrain_nlptest_acc,fmt='%.6f')
        		savetxt(resultdir+'/rectrain_lptest_acc/'+accresultstr+'.txt',rectrain_lptest_acc,fmt='%.6f')

