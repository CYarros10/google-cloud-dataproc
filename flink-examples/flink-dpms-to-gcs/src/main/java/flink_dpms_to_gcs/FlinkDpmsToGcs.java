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

package flink_dpms_to_gcs;

import java.util.List;
import java.util.ArrayList;

import org.apache.flink.table.api.TableResult;
import org.apache.flink.table.catalog.hive.HiveCatalog;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.connector.file.sink.FileSink;

import org.apache.flink.api.common.serialization.SimpleStringEncoder;
import org.apache.flink.streaming.api.functions.sink.filesystem.bucketassigners.BasePathBucketAssigner;
import org.apache.flink.core.fs.Path;
import org.apache.flink.types.Row;
import org.apache.flink.util.CloseableIterator;

public final class FlinkDpmsToGcs {

    public static void main(String[] args) throws Exception {

        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        StreamTableEnvironment tableEnvSelectJob = StreamTableEnvironment.create(env);

        String hiveCatalog         = "hcat";
        String hiveDb              = "flinktest";
        String hiveConfDir         = "/etc/hive/conf";
        String hiveTable           = "myTable";
        String gcsPath             = "gs://cy-sandbox/dataproc/flinky/from-hive";

        HiveCatalog hive = new HiveCatalog(hiveCatalog, hiveDb, hiveConfDir);

        tableEnvSelectJob.registerCatalog("hcat", hive);
        tableEnvSelectJob.useCatalog("hcat");
        tableEnvSelectJob.useDatabase("flinktest");

        TableResult tableResult = tableEnvSelectJob.executeSql("select * from "+hiveTable+";");
        CloseableIterator<Row> it = tableResult.collect();
        List<String> list = new ArrayList<>();
        while (it.hasNext()) {
            list.add(it.next().toString()); // +I[1, christian] Need to format appropriately based on data.
        }
        DataStream<String> dataStream = env.fromCollection(list);
        FileSink<String> gcsSink = FileSink
                .forRowFormat(new Path(gcsPath), new SimpleStringEncoder<String>())
                .withBucketAssigner(new BasePathBucketAssigner<>())
                .build();
        dataStream.sinkTo(gcsSink);
        env.execute();
    }
}