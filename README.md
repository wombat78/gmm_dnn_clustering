Mon Jul 13 17:39:39 SGT 2015
 Authors: BP, He Di
----------------------------

0. Introduction and overview.

This implements a two-pass decoding procedure, in which the first pass decides which senone state to score, and optionally decides which frames to perform full decoding for.

This has been used for - TIMIT, RM, WSJ data sets.

This folder structure plugs in directly into a egs directory from kaldi master branch in github.

1. Manifest

utils/pexec   - tool script that executes shell commands in parallel
steps/decode-ccnc.sh  - implementation of two pass decoding using 
                          coarse->narrow class activations
clusters/     - some example broad clusters using computed with KL-divergence
bin/2pass     - helper scripts, read each individual file for details.
scripts/      - more generic helper script which help to build kaldi models
                for the first pass decoding
run-main.sh - main script to generate test conditions and run over RM test set.

1a. Scripts
Read top part of most scripts to get documentation, or run without arguments (python only).

scripts/expand_bc_active_to_nc_active_states.pl
    - uses an activation map to convert activated broad clusters to a list
      of activated narrow clusters.
    - an activation map is a text file. First column is the index to a broad
      cluster, the remaining colums are indices to the narrow cluster. 
    - e.g. if a line reads 3 4 8 32 44, it means that if broad cluster 3 
      is active, cluster 4 8 32 44 narrow clusters (i.e. senones) need to be 
      scored
    - this script reads in text format kaldi archive files. each utterance
      contains a matrix with 
    - the input is a vector of vectors. (i.e. use kaldi copy-int-vector-vector)
    - Each vector corresponds to a frame. Each entry in each frame corresponds 
      to  a list of active tokens (be it broad class, as input or narrow class
      as output)

scripts/like-to-active-states.pl
    - parses a likelihood file (this is a giant matrix of likelihood of being
      in state/senone k given the frame j), and decide which senones should be 
      active. Likelihood is a matrix (e.g. copy-matrix), each line corresponds
      to a frame, each entry corresponds to the likelihood of the frame j 
      observation vector being produced by senone i. (matrix m_(i,j))

scripts/convert_cluster_to_kaldi_mdl.py
    - converts cluster format into a kaldi model file. Needs to have a base
    - kaldi model with transitions. It generates the GMM portion part.

scripts/filter-likelihoods.pl
    - sets likelihoods above a certain threshould to maximum.

scripts/filt-post-to-active-bc-tokens.pl


scripts/convert_kaldi_mdl_to_htk2.py
    - converts kaldi model to htk format

scripts/convert_cluster_to_activationmap.py
    - reads in a cluster file from cluster


2. Notes on decoding simulation.
The decoder simulates the 2 pass algorithm by first scoring GMMs in the first pass, then scanning the output log-likelihood scores and setting things that don''t need to be calculated, to a very negative log-likelihood. The full set of log-likelihoods is sent to the second pass which actually does a full decoding (with beam pruning). 

A more efficient implementation can possibly be implemented by generating a lattice in the first pass, then rescoring in the second pass.

3. Example use

a. set up options in run-main.sh
b. run run-main.sh to generate R.sh
c. call pexec R.sh to run each decoding line in parallel.

R.sh contains calls to decode-ccnc.sh which does the actual decoding


