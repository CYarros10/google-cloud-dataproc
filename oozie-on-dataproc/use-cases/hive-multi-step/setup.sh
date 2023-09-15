export USE_CASE=all_formats_hive
export HOST_NAME=bq-export-sandbox-dp-cluster-oozie-m
export PORT=110000
export SCRIPT=all_formats_hive
export OOZIE_DIR=~/oozie/apps

# make sure oozie dirs exist
mkdir ~/oozie 
mkdir $OOZIE_DIR 
mkdir $OOZIE_DIR/$USE_CASE
mkdir $OOZIE_DIR/$USE_CASE/scripts

# Local
cp ~/$USE_CASE/workflow.xml $OOZIE_DIR/$USE_CASE/workflow.xml
cp ~/$USE_CASE/scripts/* $OOZIE_DIR/$USE_CASE/scripts/
cp ~/$USE_CASE/job.properties.template $OOZIE_DIR/$USE_CASE/job.properties
sed -i "s|%%HOST_NAME%%|$HOST_NAME|g" $OOZIE_DIR/$USE_CASE/job.properties
sed -i "s|%%USE_CASE%%|$USE_CASE|g" $OOZIE_DIR/$USE_CASE/job.properties
sed -i "s|%%SCRIPT%%|$SCRIPT|g" $OOZIE_DIR/$USE_CASE/job.properties

# HDFS
hadoop fs -rm -r /user/yarros/oozie/apps/$USE_CASE
hdfs dfs -mkdir /user/yarros/oozie/apps/$USE_CASE
hadoop fs -put -f $OOZIE_DIR/$USE_CASE/ /user/yarros/oozie/apps/

# Oozie
oozie job -oozie http://$HOST_NAME:11000/oozie -config $OOZIE_DIR/$USE_CASE/job.properties -run