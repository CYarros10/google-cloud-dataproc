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

package flink_dpms_read_write;

import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.TableEnvironment;
import org.apache.flink.table.catalog.hive.HiveCatalog;

public final class FlinkDpmsReadWrite {

    public static void main(String[] args) throws Exception {

        EnvironmentSettings settings = EnvironmentSettings.newInstance().inBatchMode().build();

        String name            = "hcat";
        String defaultDatabase = "flinktest";
        String hiveConfDir     = "/etc/hive/conf";
        HiveCatalog hive = new HiveCatalog(name, defaultDatabase, hiveConfDir);

        // need multiple environments for multiple jobs otherwise ClusterDeploymentException: Could not deploy Yarn job cluster.

        TableEnvironment tableEnvCreateJob = TableEnvironment.create(settings);
        // set the HiveCatalog as the current catalog of the session
        tableEnvCreateJob.registerCatalog("hcat", hive);
        tableEnvCreateJob.useCatalog("hcat");
        tableEnvCreateJob.useDatabase("flinktest");
        tableEnvCreateJob.executeSql("CREATE TABLE IF NOT EXISTS flinkyTable(id int) with ('connector'='hive');"); // flink sql

        TableEnvironment tableEnvInsertJob = TableEnvironment.create(settings);
        tableEnvInsertJob.registerCatalog("hcat", hive);
        tableEnvInsertJob.useCatalog("hcat");
        tableEnvInsertJob.useDatabase("flinktest");
        tableEnvInsertJob.executeSql("INSERT INTO flinkyTable SELECT 1;"); // flink sql

        TableEnvironment tableEnvSelectJob = TableEnvironment.create(settings);
        tableEnvSelectJob.registerCatalog("hcat", hive);
        tableEnvSelectJob.useCatalog("hcat");
        tableEnvSelectJob.useDatabase("flinktest");
        tableEnvSelectJob.executeSql("select * from flinkyTable;").print();
    }
}