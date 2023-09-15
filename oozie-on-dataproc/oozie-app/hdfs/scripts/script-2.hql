DROP TABLE comments_csv;
DROP TABLE comments_csv_gz;
DROP TABLE comments_json;
DROP TABLE comments_json_gz;
DROP TABLE comments_avro;
DROP TABLE comments_avro_snappy;
DROP TABLE comments_avro_deflate;
DROP TABLE comments_parquet;
DROP TABLE comments_parquet_gzip;
DROP TABLE comments_parquet_snappy;

CREATE EXTERNAL TABLE comments_csv (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words int,
    reading_ease_score float,
    reading_ease string,
    reading_grade_level string,
    sentiment_score float,
    censored int,
    positive int,
    neutral int,
    negative int,
    subjectivity_score float,
    subjective int,
    url string,
    comment_date timestamp,
    comment_timestamp timestamp,
    comment_hour int,
    comment_year int,
    comment_month int,
    comment_day int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ( "separatorChar" = "\t" ) 
STORED AS TEXTFILE
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/CSV'
;

CREATE EXTERNAL TABLE comments_csv_gz (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words int,
    reading_ease_score float,
    reading_ease string,
    reading_grade_level string,
    sentiment_score float,
    censored int,
    positive int,
    neutral int,
    negative int,
    subjectivity_score float,
    subjective int,
    url string,
    comment_date timestamp,
    comment_timestamp timestamp,
    comment_hour int,
    comment_year int,
    comment_month int,
    comment_day int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ( "separatorChar" = "\t" ) 
STORED AS TEXTFILE
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/CSV_GZIP'
;

CREATE EXTERNAL TABLE comments_json (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words string,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored string,
    positive string,
    neutral string,
    negative string,
    subjectivity_score double,
    subjective string,
    url string,
    comment_date string,
    comment_timestamp string,
    comment_hour string,
    comment_year string,
    comment_month string,
    comment_day string
)
ROW FORMAT SERDE
'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/JSON/'
;

CREATE EXTERNAL TABLE comments_json_gz (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words string,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored string,
    positive string,
    neutral string,
    negative string,
    subjectivity_score double,
    subjective string,
    url string,
    comment_date string,
    comment_timestamp string,
    comment_hour string,
    comment_year string,
    comment_month string,
    comment_day string
)
ROW FORMAT SERDE
'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/JSON_GZIP/'
;

CREATE EXTERNAL TABLE comments_avro (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words bigint,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored bigint,
    positive bigint,
    neutral bigint,
    negative bigint,
    subjectivity_score double,
    subjective bigint,
    url string,
    comment_date bigint,
    comment_timestamp bigint,
    comment_hour bigint,
    comment_year bigint,
    comment_month bigint,
    comment_day bigint
)
STORED AS AVRO
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/AVRO'
;

CREATE EXTERNAL TABLE comments_avro_snappy (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words bigint,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored bigint,
    positive bigint,
    neutral bigint,
    negative bigint,
    subjectivity_score double,
    subjective bigint,
    url string,
    comment_date bigint,
    comment_timestamp bigint,
    comment_hour bigint,
    comment_year bigint,
    comment_month bigint,
    comment_day bigint
)
STORED AS AVRO
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/AVRO_SNAPPY'
TBLPROPERTIES("avro.compress"="snappy")
;

CREATE EXTERNAL TABLE comments_avro_deflate (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words bigint,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored bigint,
    positive bigint,
    neutral bigint,
    negative bigint,
    subjectivity_score double,
    subjective bigint,
    url string,
    comment_date bigint,
    comment_timestamp bigint,
    comment_hour bigint,
    comment_year bigint,
    comment_month bigint,
    comment_day bigint
)
STORED AS AVRO
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/AVRO_DEFLATE'
TBLPROPERTIES("avro.compress"="deflate")
;

CREATE EXTERNAL TABLE comments_parquet (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words bigint,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored bigint,
    positive bigint,
    neutral bigint,
    negative bigint,
    subjectivity_score double,
    subjective bigint,
    url string,
    comment_date bigint,
    comment_timestamp bigint,
    comment_hour bigint,
    comment_year bigint,
    comment_month bigint,
    comment_day bigint
)
STORED AS PARQUET
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/PARQUET'
;

CREATE EXTERNAL TABLE comments_parquet_snappy (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words bigint,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored bigint,
    positive bigint,
    neutral bigint,
    negative bigint,
    subjectivity_score double,
    subjective bigint,
    url string,
    comment_date bigint,
    comment_timestamp bigint,
    comment_hour bigint,
    comment_year bigint,
    comment_month bigint,
    comment_day bigint
)
STORED AS PARQUET
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/PARQUET_SNAPPY'
TBLPROPERTIES("parquet.compress"="SNAPPY")
;

CREATE EXTERNAL TABLE comments_parquet_gzip (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words bigint,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored bigint,
    positive bigint,
    neutral bigint,
    negative bigint,
    subjectivity_score double,
    subjective bigint,
    url string,
    comment_date bigint,
    comment_timestamp bigint,
    comment_hour bigint,
    comment_year bigint,
    comment_month bigint,
    comment_day bigint
)
STORED AS PARQUET
LOCATION
 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/PARQUET_GZIP'
TBLPROPERTIES("parquet.compress"="GZIP")
;

msck repair table comments_csv;
msck repair table comments_csv_gz;
msck repair table comments_json;
msck repair table comments_json_gz;
msck repair table comments_avro;
msck repair table comments_avro_snappy;
msck repair table comments_avro_deflate;
msck repair table comments_parquet;
msck repair table comments_parquet_snappy;
msck repair table comments_parquet_gzip;


insert overwrite  directory 'gs://bq-export-sandbox-services/comments_raw_bq_format_testing/oozie-output' 
row format delimited 
fields terminated by ',' stored as textfile 
select * from comments_parquet_gzip limit 10;