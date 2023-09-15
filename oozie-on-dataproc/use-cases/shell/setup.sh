export USE_CASE=gcloud_submit
export CLUSTER=bq-export-sandbox-dp-cluster-oozie-2
export HOST_NAME=$CLUSTER-m
export PORT=11000

# Local
mkdir ~/oozie 
mkdir ~/oozie/apps 
mkdir ~/oozie/apps/$USE_CASE
mkdir ~/oozie/apps/$USE_CASE/scripts
cp ~/$USE_CASE/workflow.xml ~/oozie/apps/$USE_CASE/workflow.xml
cp ~/$USE_CASE/scripts/* ~/oozie/apps/$USE_CASE/scripts/
cp ~/$USE_CASE/job.properties.template ~/oozie/apps/$USE_CASE/job.properties
sed -i "s|%%HOST_NAME%%|$HOST_NAME|g" ~/oozie/apps/$USE_CASE/job.properties
sed -i "s|%%USE_CASE%%|$USE_CASE|g" ~/oozie/apps/$USE_CASE/job.properties
sed -i "s|%%SCRIPT%%|$SCRIPT|g" ~/oozie/apps/$USE_CASE/job.properties
sed -i "s|%%CLUSTER%%|$CLUSTER|g" ~/oozie/apps/$USE_CASE/job.properties
sed -i "s|%%REGION%%|$REGION|g" ~/oozie/apps/$USE_CASE/job.properties

# HDFS
hadoop fs -rm -r /user/yarros/oozie/apps/$USE_CASE
hdfs dfs -mkdir /user/yarros/oozie/
hdfs dfs -mkdir /user/yarros/oozie/apps/
hdfs dfs -mkdir /user/yarros/oozie/apps/$USE_CASE
hadoop fs -put -f ~/oozie/apps/$USE_CASE/ /user/yarros/oozie/apps/

# Oozie
oozie job -oozie http://$HOST_NAME:11000/oozie -config ~/oozie/apps/$USE_CASE/job.properties -run
