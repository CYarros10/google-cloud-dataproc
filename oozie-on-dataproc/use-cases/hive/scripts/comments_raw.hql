CREATE EXTERNAL TABLE comments_raw (
    comment_id string,
    subreddit string,
    author string,
    comment_text string,
    total_words int,
    reading_ease_score double,
    reading_ease string,
    reading_grade_level string,
    sentiment_score double,
    censored int,
    positive int,
    neutral int,
    negative int,
    subjectivity_score double,
    subjective int,
    url string,
    comment_date string,
    comment_timestamp string,
    comment_hour int,
    comment_year int,
    comment_month int,
    comment_day int
)
ROW FORMAT SERDE
'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION
 'gs://bq-export-sandbox-services/historical_comments_new/'
;

msck repair table comments_raw;
