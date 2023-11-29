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

package flink_pubsub;

// [START FlinkPubSubClientExample]

import java.nio.charset.StandardCharsets;
import java.time.Duration;

import com.google.pubsub.v1.PubsubMessage;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.gcp.pubsub.common.PubSubDeserializationSchema;
import org.apache.flink.streaming.connectors.gcp.pubsub.PubSubSource;
import org.apache.flink.streaming.connectors.gcp.pubsub.PubSubSink;
import org.apache.flink.api.common.typeinfo.TypeInformation;

public class FlinkPubSubClient {

    public static void main(String[] args) throws Exception {
        // TODO(developer): Replace these variables before running the sample.
        String projectId = "your-project-id";
        String inboundSubscriptionId = "your-inbound-subscription-id";
        String outboundTopicName = "your-outbound-topic-name";

        if (args.length == 3) {
            projectId = args[0];
            inboundSubscriptionId = args[1];
            outboundTopicName = args[2];
        }

        System.out.println("Project ID: " + projectId);
        System.out.println("Inbound Subscription ID: " + inboundSubscriptionId);
        System.out.println("Outbound Topic Name: " +  outboundTopicName);

        StreamExecutionEnvironment streamExecEnv = StreamExecutionEnvironment.getExecutionEnvironment();
        streamExecEnv.enableCheckpointing(10000);

        PubSubSource<String> pubsubSource = PubSubSource.newBuilder()
                .withDeserializationSchema(new StringDeserializationSchema())
                .withProjectName(projectId)
                .withSubscriptionName(inboundSubscriptionId)
                .withPubSubSubscriberFactory(100, Duration.ofSeconds(600), 100)
                .build();

        DataStreamSource<String> streamSource = streamExecEnv.addSource(pubsubSource);

        // this is the outbound topic where the messages will be sent
        final PubSubSink<String> outboundSink = PubSubSink.newBuilder()
                .withSerializationSchema(new SimpleStringSchema())
                .withProjectName(projectId)
                .withTopicName(outboundTopicName)
                .build();

        streamSource.addSink(outboundSink);

        streamExecEnv.execute();
    }

    public static class StringDeserializationSchema implements PubSubDeserializationSchema<String> {

        @Override
        public boolean isEndOfStream(String nextElement) {
            return false;
        }

        @Override
        public String deserialize(PubsubMessage pubsubMessage) {
            return new String(pubsubMessage.getData().toByteArray(), StandardCharsets.UTF_8);
        }

        @Override
        public TypeInformation<String> getProducedType() {
            return TypeInformation.of(String.class);
        }
    }
}
// [END FlinkPubSubClientExample]