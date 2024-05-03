DROP FUNCTION IF EXISTS CalculateMovieRatingScore;

DELIMITER !

-- UDF to calculate a combined rating score for a movie
-- It averages user ratings from watch_history and the IMDb rating from ratings table.
-- Handles NULL values by treating them as 0 for the purpose of this calculation.
CREATE FUNCTION CalculateMovieRatingScore(movie_id INT)
RETURNS DECIMAL(3, 2) DETERMINISTIC
BEGIN
    DECLARE avg_user_rating DECIMAL(3, 2);
    DECLARE imdb_rating DECIMAL(3, 2);
    DECLARE combined_score DECIMAL(3, 2);

    SELECT COALESCE(AVG(user_rating), 0) INTO avg_user_rating FROM watch_history WHERE movie_id = movie_id;
    SELECT COALESCE(imdb_rating, 0) INTO imdb_rating FROM ratings WHERE movie_id = movie_id;

    -- Check to avoid division by zero if both ratings are zero
    IF avg_user_rating = 0 AND imdb_rating = 0 THEN
        SET combined_score = 0;
    ELSE
        SET combined_score = (avg_user_rating + imdb_rating) / 2;
    END IF;

    RETURN combined_score;
END !

DROP PROCEDURE IF EXISTS UpdateUserPreferences;
-- Procedure to update user preferences based on their latest interactions
-- Adds error handling for insertions and deletions.
CREATE PROCEDURE UpdateUserPreferences(user_id INT, movie_id INT, liked BOOLEAN)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle errors, potentially logging them or notifying an admin
        ROLLBACK;
    END;

    START TRANSACTION;
    IF liked THEN
        -- Check if the preference already exists to avoid duplicates
        IF NOT EXISTS (SELECT 1 FROM user_preferences WHERE user_id = user_id AND movie_id = movie_id) THEN
            INSERT INTO user_preferences(user_id, movie_id, actor_id)
            SELECT user_id, movie_id, actor_id FROM cast WHERE movie_id = movie_id;
        END IF;
    ELSE
        DELETE FROM user_preferences WHERE user_id = user_id AND movie_id = movie_id;
    END IF;
    COMMIT;
END !

-- Procedure to update a movie's rating (Placeholder)
DROP PROCEDURE IF EXISTS UpdateMovieRating;
CREATE PROCEDURE UpdateMovieRating(movie_id INT)
BEGIN
    -- Example implementation; adjust according to your requirements
    DECLARE new_rating DECIMAL(3, 2);
    SET new_rating = CalculateMovieRatingScore(movie_id);
    UPDATE ratings SET imdb_rating = new_rating WHERE movie_id = movie_id;
END !

DROP TRIGGER IF EXISTS trg_UpdateMovieRating;
-- Trigger to automatically update the movie rating after a new user rating is inserted
CREATE TRIGGER trg_UpdateMovieRating AFTER INSERT ON watch_history
FOR EACH ROW
BEGIN
    CALL UpdateMovieRating(NEW.movie_id);
END !

DELIMITER ;
