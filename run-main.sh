# Tue Jun 16 11:05:57 SGT 2015
# Author: BP
#   date: Fri Jun 19 14:29:34 SGT 2015

# THIS IS THE TOP LEVEL FILE
# This runs a set of cluster-activated (prepruned decoding) experiments

# temporary file for shel commands to run

# old setup for WSJ
#CLUSTER_FILE=clusters/clusBP_radTo5_wsj_4674to935_8.txt
#MODEL_FILE=exp/tri2b-ccnc/wsj_s5_tri2b_6000_15000.mdl.txt

# Set number of mixtures per cluster and infile here
NUMMIX=4

# set shis option to the clustering result fild
CLUSTER_FILE=clusters/clusBP_withComfu_rm40D_randTo4_1480to296_result-2.txt
MODEL_FILE=exp_rm/rm_s5_tri2b_mmi_b0.05.mdl.txt
MODEL_DIR=exp_rm/tri2b_mmi_b0.05/
DECODE_GRAPH=exp_rm/tri2b_graph/

# set up the names of testsets to run for the resource management task
TESTSETS='rm_test rm_test_feb89 rm_test_feb91 rm_test_mar87 rm_test_oct87 rm_test_oct89 rm_test_sep92'

## these are settings from the RM original model
NUMMIX=5
NUMDIM=39
CLUSTER_FILE=clusters/clusBP_rm39D_randTo5_1451to296_result.fixed.txt
MODEL_FILE=exp_rm/rm_s5_tri2a.mdl.txt
MODEL_DIR=exp_rm/tri2a/
DECODE_GRAPH=exp_rm/tri2a_graph/
TAG='c148_39D_5_RM_4mix'

## these are settings for the confusion model RM original model
NUMMIX=4
NUMDIM=40
CLUSTER_FILE=clusters/clusBP_withComfu_rm40D_randTo4_1480to296_result-2.txt
MODEL_FILE=exp_rm/rm_s5_tri2b_mmi_b0.05.mdl.txt
MODEL_DIR=exp_rm/tri2b_mmi_b0.05/
DECODE_GRAPH=exp_rm/tri2b_graph/
TAG='c296_CM_40D_RM_4mix'

# TMP_BASH_FILE is a temporary file that is generated that contains decoding istructions of different parameters. Each line in the generated shell script can be sent to a cluster machine to be processed in parallel
TMP_BASH_FILE=R.sh
RES_FILE=results.tex
TMPDIR=tmp/

# figure out intermediate file names
cluster_name=`basename $CLUSTER_FILE | sed 's/.txt//;'`
model_name=`basename $MODEL_FILE | sed 's/.mdl.txt//;'`
model_dir=`dirname $MODEL_FILE`
new_model_file=$model_dir/$model_name.$cluster_name.mdl.txt
amap_file=$TMPDIR/$model_name.$cluster_name.amap.txt

# create the new model file and activation map
echo python scripts/convert_cluster_to_activationmap.py --DIM $NUMDIM --NUMMIX $NUMMIX $CLUSTER_FILE $amap_file 
python scripts/convert_cluster_to_activationmap.py --DIM $NUMDIM --NUMMIX $NUMMIX $CLUSTER_FILE $amap_file || exit 1

echo python scripts/convert_cluster_to_kaldi_mdl.py $CLUSTER_FILE $MODEL_FILE $new_model_file
python scripts/convert_cluster_to_kaldi_mdl.py --DIM $NUMDIM --NUMMIX $NUMMIX $CLUSTERS $CLUSTER_FILE $MODEL_FILE $new_model_file || exit 1

if [ -e $TMP_BASH_FILE ]; then
  echo deleting script file $TMP_BASH_FILE
  rm $TMP_BASH_FILE
fi


# generate a list of things to run
for testset in $TESTSETS; do
 for dtime in 0 1 2 3 4; do
    #for active_clusters in 286 143 72 36 16; do 
    for active_clusters in 296 112 74 38 19 9; do 
 #for dtime in 0; do
tag=$TAG.ac$active_clusters.d$dtime
echo bash steps/decode-ccnc.sh --nj 8 --ACLUSTERMAP $amap_file --ACTIVE_CLUSTERS $active_clusters --DTIME $dtime $DECODE_GRAPH data/$testset $MODEL_DIR/decode_${testset}_ccnc_tgpr.$tag $new_model_file \> logs/$tag.log >> $TMP_BASH_FILE
  done
 done
done

echo generated shell script with `wc -l R.sh` commands

# run them in parallel
echo start running!
#pexec -v -e -d -n 2 R.sh

# collect bc and nc confusions, write them out in a table
#echo > C
#for job in 1 2 3 4 ; do 
#perl collect-confusions.pl  exp/tri2b-ccnc/test/test/test.topll.$job.gz exp/tri2b-ccnc/test/test/test.top-fm-ll.$job.gz |& tee $RES_FILE
#done
