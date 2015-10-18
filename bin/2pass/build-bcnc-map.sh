#!/bin/bash
# generates broad-class (monophone) to narrow class (triphone) activation map

BC=exp_timit_ph_cmvn2/mono0a_1000/final.mdl
GRAPHDIR=`dirname $BC`/graph_bg/
BC=exp_timit_ph_cmvn2/mono_128/final.mdl
BC=exp_timit_ccnc/mono_128/final.mdl

NC=exp_timit_ph_cmvn2/tri2b_1500_6000/final.mdl
OUT=exp_timit_bcnc/mono_128-to-tri2b_1500_6000.senone.map.txt
TMP=tmp/

show-transitions $GRAPHDIR/phones.txt $BC | grep 'Transition-state' | awk '{ print $5 "-" $8 " " $11;}' 

show-transitions $GRAPHDIR/phones.txt $BC |\
     grep 'Transition-state' | awk '{ print $5 "-" $8 " " $11;}' |\
     perl utils/spk2utt_to_utt2spk.pl |\
     perl utils/utt2spk_to_spk2utt.pl \
        > $TMP/bc-activation-list.txt

show-transitions `dirname $NC`/graph_bg/phones.txt $NC |\
     grep 'Transition-state' | awk '{ print $5 "-" $8 " " $11;}' |\
     perl utils/spk2utt_to_utt2spk.pl |\
     perl utils/utt2spk_to_spk2utt.pl \
        > $TMP/nc-activation-list.txt

echo `perl linecnt $TMP/bc-activation-list.txt`

coljoin --inner $TMP/bc-activation-list.txt $TMP/nc-activation-list.txt > $OUT
