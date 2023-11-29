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

package flink_gcs_to_gcs;

import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import org.apache.flink.api.common.serialization.SimpleStringEncoder;
import org.apache.flink.streaming.api.functions.sink.filesystem.bucketassigners.BasePathBucketAssigner;
import org.apache.flink.core.fs.Path;
import org.apache.flink.connector.file.sink.FileSink;


public class FlinkGcsToGcs {

    public static void main(String[] args) throws Exception {
        // TODO(developer): Replace these variables before running the sample.
        String projectId            = "cy-artifacts";
        String gcsSourcePath        = "gs://cy-sandbox/sample_data/Romeo-and-Juliet-prologue.txt";
        String gcsDestinationPath   = "gs://cy-sandbox/dataproc/flinky/direct/";

        if (args.length == 2) {
            projectId = args[0];
            gcsSourcePath = args[1];
        }

        final StreamExecutionEnvironment streamExecEnv = StreamExecutionEnvironment.getExecutionEnvironment();

        // READ FROM GCS
        DataStream<String> dataStreamFromGcs = streamExecEnv.readTextFile(gcsSourcePath);

        //WRITE TO GCS
        FileSink<String> gcsSink = FileSink
                .forRowFormat(new Path(gcsDestinationPath), new SimpleStringEncoder<String>())
                .withBucketAssigner(new BasePathBucketAssigner<>())
                .build();
        dataStreamFromGcs.sinkTo(gcsSink);

        streamExecEnv.execute();
    }
}