#!/bin/bash

# Run in Cloud Shell to set up your project and deploy solution via terraform.

usage() {
    echo "Usage: [ -p projectId ] [ -r region ] [ -b bucket ]  [ -c cluster ] [ -t timestamp ] "
}
export -f usage

while getopts ":p:r:b:c:t:" opt; do
    case $opt in
        p ) projectId="$OPTARG";;
        r ) region="$OPTARG";;
        b ) bucket="$OPTARG";;
        c ) cluster="$OPTARG";;
        t ) timestamp="$OPTARG";;
        \?) echo "Invalid option -$OPTARG"
        usage
        exit 1
        ;;
    esac
done

echo "===================================================="
echo " Inputs ..."
echo " Project ID: ${projectId}" 
echo " Region: ${region}" 
echo " GCS Bucket: ${bucket}" 
echo " Dataproc Cluster Name: ${cluster}"
echo " Timestamp: ${timestamp}"

echo "===================================================="
echo " Setting up project and enabling APIs ..."

gcloud config set project "$projectId"

gcloud services enable storage-component.googleapis.com 
gcloud services enable compute.googleapis.com  
gcloud services enable servicenetworking.googleapis.com 
gcloud services enable iam.googleapis.com 
gcloud services enable dataproc.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable bigquery.googleapis.com


echo "===================================================="
echo " Removing old infrastructure ..."


gsutil -m rm -r gs://"$bucket"
bq rm -t=true -f=true "$bucket".myTableCopy
bq rm -t=true -f=true "$bucket".yellow_trips_copy


echo "===================================================="
echo " Building infrastructure ..."

gsutil mb -c regional -l "$region" gs://"$bucket"

bq mk --dataset "$bucket"

gsutil cp scripts/spark_average_speed.py gs://"$bucket"/scripts/spark_average_speed.py

echo "===================================================="
echo " Loading data ..."

bq cp nyc-tlc:yellow.trips "$bucket".tempCopy
bq query --destination_table="$projectId":"$bucket".yellow_trips_copy "select * from ${bucket}.tempCopy limit 10000000"

bq extract \
  --destination_format=NEWLINE_DELIMITED_JSON \
  "$projectId":"$bucket".yellow_trips_copy \
  gs://"$bucket"/raw-"$timestamp"/nyc-tlc-yellow-*.json


echo "===================================================="
echo " Import autoscaling policies ..."

gcloud dataproc autoscaling-policies import sizing-cluster-autoscaling-policy \
  --source=templates/sizing-cluster-autoscaling-policy.yml \
  --region="$region"

gcloud dataproc autoscaling-policies import final-cluster-autoscaling-policy \
  --source=templates/final-cluster-autoscaling-policy.yml \
  --region="$region"

echo "===================================================="
echo " Customizing final workflow template ..."

sed -i "s|%%BUCKET_NAME%%|$bucket|g" templates/final-cluster-wft.yml
sed -i "s|%%TIMESTAMP%%|$timestamp|g" templates/final-cluster-wft.yml
sed -i "s|%%REGION%%|$region|g" templates/final-cluster-wft.yml

echo "===================================================="
echo " Creating sizing cluster ..."

gcloud dataproc clusters create "$cluster"-sizing \
  --master-machine-type=n2-standard-2 \
  --worker-machine-type=n2-standard-2 \
  --master-boot-disk-type=pd-standard \
  --master-boot-disk-size=1000GB \
  --autoscaling-policy=sizing-cluster-autoscaling-policy \
  --region="$region"

