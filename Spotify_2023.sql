-- Dataset : Spotify Top 50 Tracks 2023
-- Source  : https://www.kaggle.com/datasets/yukawithdata/spotify-top-tracks-2023?select=top_50_2023.csv
-- Quried using : MySQl Workbench '8.0.37-0ubuntu0.22.04.3'
CREATE DATABASE musicDB;
USE musicDB;

-- Import the dataset into the 'top_50_2023' table
-- Note: Imported using Table Data Import Wizard in MySQL Workbench


SELECT * FROM top_50_2023;

-- Find the top 10 artists based on average popularity and count of songs in the top 50
SELECT
    artist_name,
    COUNT(track_name) AS song_count, -- Number of songs for each artist
    ROUND(AVG(popularity), 0) AS average_popularity -- Average popularity rounded to the nearest whole number
FROM top_50_2023
GROUP BY artist_name
ORDER BY average_popularity DESC
LIMIT 10;


-- Get the top 10 disco songs based on their danceability score
SELECT
    track_name,
    artist_name,
    danceability
FROM top_50_2023
-- WHERE genres LIKE '%disco%' -- Filter for disco genre
ORDER BY danceability DESC
LIMIT 10;


-- Calculate the standard deviation of popularity using Common Table Expressions (CTE)
WITH stats AS (
    SELECT AVG(popularity) AS avg_popularity
    FROM top_50_2023
),
variance AS (
    SELECT AVG((popularity - stats.avg_popularity) * (popularity - stats.avg_popularity)) AS variance
    FROM top_50_2023, stats
)
SELECT 
    SQRT(variance.variance) AS stddev_popularity -- Standard deviation of popularity
FROM variance;


-- Get the top 10 non-explicit songs for a kids' party based on danceability and liveness
SELECT
    track_name,
    CONCAT(FLOOR(duration_ms / 60000), ':', LPAD(duration_ms DIV 1000 MOD 60, 2, '0')) AS duration -- Format duration as minutes:seconds
FROM top_50_2023
WHERE is_explicit = 'False' -- Filter for non-explicit content
ORDER BY danceability DESC, liveness DESC -- Order by danceability and liveness
LIMIT 10;


-- Create a function to calculate the total duration of a playlist consisting of the top 10 tracks
DELIMITER //

CREATE FUNCTION get_total_duration()
RETURNS VARCHAR(10) 
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_duration_ms BIGINT;
    DECLARE minutes INT;
    DECLARE seconds INT;
    DECLARE total_duration VARCHAR(10);

    -- Calculate the total duration in milliseconds
    SELECT SUM(duration_ms) INTO total_duration_ms
    FROM (
        SELECT duration_ms
        FROM top_50_2023
        WHERE is_explicit = 'False'
        ORDER BY danceability DESC, liveness DESC
        LIMIT 10
    ) AS selected_songs;

    -- Convert the total duration to minutes and seconds
    SET minutes = FLOOR(total_duration_ms / 60000);
    SET seconds = FLOOR(total_duration_ms / 1000) MOD 60;

    -- Format the total duration as minutes:seconds
    SET total_duration = CONCAT(minutes, ':', LPAD(seconds, 2, '0')); -- Add leading zeros

    RETURN total_duration;
END//

DELIMITER ;

-- Call the function to get the total duration
SELECT get_total_duration();


-- Create a function to calculate the standard deviation of popularity
DELIMITER //

DROP FUNCTION IF EXISTS get_standard_deviation;

CREATE FUNCTION get_standard_deviation()
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_popularity FLOAT;
    DECLARE std_dev FLOAT;
    DECLARE n INT;

   
    SELECT AVG(popularity) INTO avg_popularity
    FROM top_50_2023;

    
    SELECT COUNT(*) INTO n
    FROM top_50_2023;

    -- Calculate the standard deviation for the dataset (sample)
    SELECT SQRT(SUM(POW(popularity - avg_popularity, 2)) / (n - 1)) INTO std_dev 
    FROM top_50_2023;

    RETURN std_dev;
END//

DELIMITER ;

SELECT get_standard_deviation();



-- Calculate the average popularity of pop songs from the top 50 tracks
SELECT AVG(popularity) AS average__pop_popularity
FROM top_50_2023
WHERE genres LIKE '%pop%'; -- Filter for pop genre

-- T0 DO : List of distinct genres