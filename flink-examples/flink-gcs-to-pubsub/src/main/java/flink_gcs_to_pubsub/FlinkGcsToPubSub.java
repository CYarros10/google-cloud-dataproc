/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flink_gcs_to_pubsub;

import org.apache.flink.api.common.serialization.SerializationSchema;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.streaming.connectors.gcp.pubsub.PubSubSink;
import org.apache.flink.runtime.state.StateBackend;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.CheckpointingMode;

public class FlinkGcsToPubSub {

    public static void main(String[] args) throws Exception {
        // TODO(developer): Replace these variables before running the sample.
        String projectId = "cy-artifacts";
        String gcsBucketPath = "gs://cy-sandbox/sample_data/Romeo-and-Juliet-prologue.txt";
        String outboundTopicName = "test";
        String fsCheckpointPath = "your-fs-checkpoint-path";

        if (args.length == 3) {
            projectId = args[0];
            gcsBucketPath = args[1];
            outboundTopicName = args[2];
        } else if (args.length == 4) {
            projectId = args[0];
            gcsBucketPath = args[1];
            outboundTopicName = args[2];
            fsCheckpointPath = args[3];
        }

        final StreamExecutionEnvironment streamExecEnv = StreamExecutionEnvironment.getExecutionEnvironment();

        /**
         * Setup checkpointing is fsCheckpointPath is specified
         * note: checkpointing is for streaming
         */
        if (!"your-fs-checkpoint-path".equals(fsCheckpointPath)) {

            System.out.println("Setting statebackend to FsStateBackend");
            StateBackend fsBackend = new FsStateBackend(fsCheckpointPath, true);
            streamExecEnv.setStateBackend(fsBackend);

            // start a checkpoint every 1000 ms
            streamExecEnv.enableCheckpointing(1000);

            // set mode to exactly-once (this is the default)
            streamExecEnv.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);

            // allow only one checkpoint to be in progress at the same time
            streamExecEnv.getCheckpointConfig().setMaxConcurrentCheckpoints(1);
        }

        // READ FROM GCS
        DataStream<String> dataStreamFromGcs = streamExecEnv.readTextFile(gcsBucketPath);

        // WRITE TO PUBSUB
        SerializationSchema<String> serializer = new SimpleStringSchema();
        SinkFunction<String> pubSubSink = PubSubSink.newBuilder()
                .withSerializationSchema(serializer)
                .withProjectName(projectId)
                .withTopicName(outboundTopicName)
                .build();
        dataStreamFromGcs.addSink(pubSubSink);

        streamExecEnv.execute();
    }
}