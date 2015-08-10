#!/bin/sh
###################################################################################
# sge_qstat_checker.sh
#
# This script infinitely pings the SGE for the number of jobs per user.
# The interval can be altered.
#
# This script was developed in order to have a running visual of the status of the 
# FUNC SGE load.
###################################################################################

while true
do
  sge qstat | awk '(NR>2){print $1,$4}' | sort | uniq | awk '{print $2}' | sort | uniq -c
  sleep 1m
done
