#!/usr/bin/python

import os
from random import sample
import errno
from numpy import *
from pylab import *
from scipy.io import *
import sys

from run_dsm import *

from mvpa2.datasets.mri import *
from mvpa2.mappers.detrend import *
from mvpa2.mappers.zscore import *
from mvpa2.clfs.svm import *
from mvpa2.generators.partition import *
from mvpa2.measures.base import *
from mvpa2.measures import *
from mvpa2.measures.searchlight import *
from mvpa2.misc.stats import *
from mvpa2.base.node import *
from mvpa2.clfs.meta import *
from mvpa2.clfs.stats import *
from mvpa2.featsel.base import *
from mvpa2.featsel.helpers import *
from mvpa2.generators.permutation import *
from mvpa2.generators.base import *
from mvpa2.mappers.fx import *
from mvpa2.measures.anova import *
from mvpa2.base.dataset import *

# Defines a funciton to only create a directory if it doesn't already exist
def mkdir_p(thisdir):
    try:
        os.makedirs(thisdir)
    except OSError as exc: 
        if exc.errno == errno.EEXIST and os.path.isdir(thisdir):
            pass

rois=('b_ahip','b_phip','b_mofc','b_ifg','b_latpar','b_phc','b_it')
sbjs = ('301','302','304','305','307','308','309','310','311','312','313')
durs = ('1','4')

basedir = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..','..')) # get the path to the katzer3 folder for whomever is running this.

# make a bunch of directories to put the results in
resultdir_all = basedir+'/scripts/rsa_results/21_rsa_singleitem_isTD/allruns_alltrials/'
mkdir_p(resultdir_all)
resultdir_allfame = basedir+'/scripts/rsa_results/21_rsa_singleitem_isTD/allruns_famous_only/'
mkdir_p(resultdir_allfame)
resultdir_allnfame = basedir+'/scripts/rsa_results/21_rsa_singleitem_isTD/allruns_nonfamous_only/'
mkdir_p(resultdir_allnfame)
resultdir_perception_all = basedir+'/scripts/rsa_results/21_rsa_singleitem_isTD/perceptionruns_alltrials/'
mkdir_p(resultdir_perception_all)
resultdir_recall_all = basedir+'/scripts/rsa_results/21_rsa_singleitem_isTD/recallruns_alltrials/'
mkdir_p(resultdir_recall_all)
resultdir_recall_fam = basedir+'/scripts/rsa_results/21_rsa_singleitem_isTD/recallruns_famous_only/'
mkdir_p(resultdir_recall_fam)

for dur in durs:
    
    for mask in rois:
        # Set up variables to append results to
        allrs = []
        famrs = []
        nfamrs = []
        percepallrs =[]
        recallallrs = []
        recallfamrs = []

        for sbj in sbjs:
            print("Computing dsm for "+mask+" for subject: " + sbj)
            sbjdir = basedir+'/sub-'+sbj+'/'
            maskdir = sbjdir+'anat/antsreg/masks/'
            datadir = sbjdir+'func/singleitem_isTD/'
            exponsetdir = basedir+'/pattern_info/singleitem/'+sbj+'/'

            print "Starting "+sbj+": "+time.strftime('%H:%M:%S',time.localtime())

            ## read in data
            trial,run,thistask,picidx,isfamous,ismanmade = loadtxt(exponsetdir+'si_pattern_info.txt',unpack=1)

            betas = datadir+'/betas_all_dur'+dur+'.nii.gz' #where are the concatenated betas?
            expds = fmri_dataset(betas,mask=maskdir+mask+'.nii.gz')

            expds.sa['chunks'] = run
            expds.sa['targets'] = ismanmade
            expds.sa['pic'] = picidx
            expds.sa['isfame'] = isfamous
            expds.sa['task'] = thistask # 1 = perception no labels, 2 = perception labels, 3 = recall
            
            dsm = run_dsm('correlation',1)
           
            # similarity measures on all runs, all trials
            design_data_all=dsm(expds)
            allrs.append(array(design_data_all).flatten())

            # similarity measures on all runs, just famous scenes
            expds_fame = expds[expds.sa.isfame == 1]
            design_data_fame = dsm(expds_fame)
            famrs.append(array(design_data_fame).flatten())

            # similarity measures on all runs, just non-famous scenes
            expds_nfame = expds[expds.sa.isfame == 0]
            design_data_nfame = dsm(expds_nfame)
            nfamrs.append(array(design_data_nfame).flatten())

            # similarity measures on all perception runs, all trials
            expds_percep_all = expds[expds.sa.task != 3]
            design_data_percepall = dsm(expds_percep_all)
            percepallrs.append(array(design_data_percepall).flatten())

            # similarity measures on recall runs, all trials
            expds_recall_all = expds[expds.sa.task == 3]
            design_data_recallall = dsm(expds_recall_all)
            recallallrs.append(array(design_data_recallall).flatten())

            # similarity measures on recall runs, just famous scenes
            expds_recall_fam = expds[(expds.sa.task == 3) & (expds.sa.isfame == 1)]
            design_data_recallfam = dsm(expds_recall_fam)
            recallfamrs.append(array(design_data_recallfam).flatten())
        
        savetxt(resultdir_all+mask+'_dur'+dur+'.txt',allrs,fmt="%.8f")
        savetxt(resultdir_allfame+mask+'_dur'+dur+'.txt',famrs,fmt="%.8f")
        savetxt(resultdir_allnfame+mask+'_dur'+dur+'.txt',nfamrs,fmt="%.8f")
        savetxt(resultdir_perception_all+mask+'_dur'+dur+'.txt',percepallrs,fmt="%.8f")
        savetxt(resultdir_recall_all+mask+'_dur'+dur+'.txt',recallallrs,fmt="%.8f")
        savetxt(resultdir_recall_fam+mask+'_dur'+dur+'.txt',recallfamrs,fmt="%.8f")
