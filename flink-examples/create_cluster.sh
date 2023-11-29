export PROJECT="cy-artifacts"
export REGION="us-central1"
export CLUSTER_NAME=flinky

gcloud dataproc clusters create ${CLUSTER_NAME} --enable-component-gateway \
  --region $REGION --num-masters 1 \
  --master-machine-type n1-standard-4 --master-boot-disk-size 1000 \
  --num-workers 2 --worker-machine-type n1-standard-4 \
  --optional-components HIVE_WEBHCAT,JUPYTER,ZOOKEEPER,FLINK \
  --project "${PROJECT}"

