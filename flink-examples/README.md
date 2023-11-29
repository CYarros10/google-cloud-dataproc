**Copyright 2023 Google. This software is provided as-is, without warranty or representation for any use or purpose. 
Your use of it is subject to your agreement with Google.**

## Pre-requisites
1. GCP project with Pub/Sub setup.
2. Create an inbound topic and subscription. In this example we have used `inbound_topic` and `inbound_topic_sub1`.
3. Create an outbound topic and subscription. In this example we have used `outbound_topic` and `outbound_topic_sub1`
4. Create a Dataproc cluster
```build
export PROJECT="your-project"
export REGION="us-central1"
export CLUSTER_NAME=flinky

gcloud dataproc clusters create ${CLUSTER_NAME} --enable-component-gateway \
--region $REGION --num-masters 1 \
--master-machine-type n1-standard-4 --master-boot-disk-size 1000 \
--num-workers 2 --worker-machine-type n1-standard-4 \
--optional-components HIVE_WEBHCAT,JUPYTER,ZOOKEEPER,FLINK \
--project "${PROJECT}"
```

5. SSH into the Dataproc Cluster and ensure these jars exist in `/lib/flink/lib`:

retrieve any you might be missing here: https://mvnrepository.com/artifact/org.apache.flink


- antlr-runtime-3.5.2.jar
- libfb303-0.9.3.jar
- hive-exec-3.1.0.jar
- flink-table-api-java-bridge_2.12-1.14.6.jar
- flink-parquet_2.12-1.14.6.jar
- flink-table-api-java-bridge-1.15.4.jar
- flink-clients-1.15.4.jar
- flink-parquet-1.15.4.jar
- flink-connector-hive_2.12-1.15.4.jar
- flink-sql-connector-hive-3.1.2_2.12-1.15.4.jar
- log4j-slf4j-impl-2.17.2.jar
- log4j-core-2.17.2.jar
- log4j-api-2.17.2.jar
- log4j-1.2-api-2.17.2.jar
- flink-shaded-zookeeper-3.8.0.jar
- flink-cep-1.15.4.jar
- flink-table-runtime-1.15.4.jar
- flink-connector-files-1.15.4.jar
- flink-csv-1.15.4.jar
- flink-json-1.15.4.jar
- flink-scala_2.12-1.15.4.jar
- flink-table-api-java-uber-1.15.4.jar
- flink-table-planner-loader-1.15.4.jar
- flink-dist-1.15.4.jar

# 1. Flink PubSub Example

## Overview
This is an example of a Dataproc Flink job that consumes messages from Pub/Sub.
The job reads messages from the inbound subscription (`PubSubSource`) and writes the messages to an outbound topic (`PubSubSink`).

## Running the example

After completing the pre-requisites, follow the steps below to run this example.

**flink/flink-pubsub**

1. Update the code to include your Google Cloud project specifics.

2. Build the example.
```build
mvn package
```

3. Copy the jar to the master node of the cluster. The file can be copied directly if `ssh` is enabled or via a GCS bucket.
```build
gsutil -m cp target/flink-pubsub-example-1.0.0.jar gs://your-bucket/tmp
```
4. Run the flink job on the master node of the cluster as shown below. The three parameters to the job are the project, inbound subscription and outbound topic.
```build
bash-4.4#
flink run \
    -m yarn-cluster \
    -p 4 \
    -ys 2 \
    -yjm 1024m \
    -ytm 2048m \
    /home/dataproc/flink/flink-pubsub-example-1.0.0.jar
```


# 2. Flink GCS to PubSub Example

**flink/flink-gcs-to-pubsub**

## Overview
This is an example of a Dataproc Flink job reads a file from GCS and pushes the content to a Pub/Sub Topic.
The job reads messages from the GCs location specified and writes the messages to an outbound topic (`PubSubSink`).

## Running the example

After completing the pre-requisites, follow the steps below to run this example.

1. Update the code to include your Google Cloud project specifics.

2. Build the example.
```build
mvn package
```

3. Copy the jar to the master node of the cluster. The file can be copied directly if `ssh` is enabled or via a GCS bucket.
```build
gsutil -m cp target/flink-pubsub-example-1.2.0.jar gs://your-bucket/tmp
```
4. Run the flink job on the master node of the cluster as shown below. The three parameters to the job are the project, GCS bucket path and outbound topic.
```build
bash-4.4#
flink run \
    -m yarn-cluster \
    -p 4 \
    -ys 2 \
    -yjm 1024m \
    -ytm 2048m \
    /home/dataproc/flink/flink-gcs-to-pubsub-1.0.0.jar
```

## Extra

To write from Pubsub to GCS, update your pubsub service account with the permissions below and create a subscription that writes to GCS.

update pubsub SA:
service-<your-project-number>@gcp-sa-pubsub.iam.gserviceaccount.com
- storage admin
and bucket level:
- Storage Legacy Bucket Reader
- Storage Legacy Object Owner

and create subscription to write to GCS.

For more info visit: https://cloud.google.com/pubsub/docs/cloudstorage

## Flink GCS to PubSub Example with Checkpointing

### Overview
This is an example of a Dataproc Flink job reads a file from GCS and pushes the content to a Pub/Sub Topic with checkpointing enabled.
The job reads messages from the GCs location specified and writes the messages to an outbound topic (`PubSubSink`).

### Running the example

After completing the pre-requisites, follow the steps below to run this example.

1. Update the code to include `String fsCheckpointPath = "your-actual-fs-checkpoint-path";`

2. Build the example.
```build
mvn package
```

3. Copy the jar to the master node of the cluster. The file can be copied directly if `ssh` is enabled or via a GCS bucket.
```build
gsutil -m cp target/flink-pubsub-example-1.0.0.jar gs://your-bucket/tmp
```
4. Run the flink job on the master node of the cluster as shown below. The three parameters to the job are the project, GCS bucket path and outbound topic.
```build
bash-4.4#
flink run \
    -m yarn-cluster \
    -p 4 \
    -ys 2 \
    -yjm 1024m \
    -ytm 2048m \
    /home/dataproc/flink/flink-gcs-to-pubsub-1.0.0.jar
```

# 3. Flink GCS to GCS Example

**flink/flink-gcs-to-gcs**

## Overview
This is an example of a Dataproc Flink job reads a file from GCS and pushes the content to another GCS location.

## Running the example

After completing the pre-requisites, follow the steps below to run this example.

1. Update the code to include your Google Cloud project specifics.

2. Build the example.
```build
mvn package
```

3. Copy the jar to the master node of the cluster. The file can be copied directly if `ssh` is enabled or via a GCS bucket.
```build
gsutil -m cp target/flink-pubsub-example-1.2.0.jar gs://your-bucket/tmp
```
4. Run the flink job on the master node of the cluster as shown below. The three parameters to the job are the project, GCS bucket path and outbound topic.
```build
bash-4.4#
flink run \
    -m yarn-cluster \
    -p 4 \
    -ys 2 \
    -yjm 1024m \
    -ytm 2048m \
    /home/dataproc/flink/flink-gcs-to-gcs-1.0.0.jar
```

# 3. Flink DPMS Read Write

**flink/flink-dpms-read-write**

## Overview
This is an example of a Dataproc Flink job reads from Hive and write to Hive.

## Running the example

After completing the pre-requisites, follow the steps below to run this example.

1. Update the code to include your Google Cloud project specifics.

2. Build the example.
```build
mvn package
```

3. Copy the jar to the master node of the cluster. The file can be copied directly if `ssh` is enabled or via a GCS bucket.
```build
gsutil -m cp target/flink-dpms-read-write-1.0.0.jar gs://your-bucket/tmp
```
4. Run the flink job on the master node of the cluster as shown below. The three parameters to the job are the project, GCS bucket path and outbound topic.
```build
bash-4.4#
flink run \
    -m yarn-cluster \
    -p 4 \
    -ys 2 \
    -yjm 1024m \
    -ytm 2048m \
    /home/dataproc/flink/flink-dpms-read-write-1.0.0.jar
```

# 3. Flink DPMS to GCS

**flink/flink-dpms-to-gcs**

## Overview
This is an example of a Dataproc Flink job reads from Hive and writes to GCS.

## Running the example

After completing the pre-requisites, follow the steps below to run this example.

1. Update the code to include your Google Cloud project specifics.

2. Build the example.
```build
mvn package
```

3. Copy the jar to the master node of the cluster. The file can be copied directly if `ssh` is enabled or via a GCS bucket.
```build
gsutil -m cp target/flink-dpms-to-gcs-1.0.0.jar gs://your-bucket/tmp
```
4. Run the flink job on the master node of the cluster as shown below. The three parameters to the job are the project, GCS bucket path and outbound topic.
```build
bash-4.4#
flink run \
    -m yarn-cluster \
    -p 4 \
    -ys 2 \
    -yjm 1024m \
    -ytm 2048m \
    /home/dataproc/flink/flink-dpms-to-gcs-1.0.0.jar
```
