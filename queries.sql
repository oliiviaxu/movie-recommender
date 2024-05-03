-- queries.sql for Movie Recommendation System

-- Query 1: Retrieve all movies released after a specific date
-- This query fetches movies released after January 1, 2020.
SELECT movie_id, movie_title, release_date, language, directed_by
FROM movies
WHERE release_date > '2020-01-01';

-- Query 2: Get top 10 latest movies by release date
-- Returns the most recently released movies, limited to 10 results.
SELECT movie_id, movie_title, release_date
FROM movies
ORDER BY release_date DESC
LIMIT 10;

-- Query 3: Find movies by a specific actor
-- Fetches all movies that feature the actor with the given actor_id.
-- Example actor_id is 1, replace with an actual actor_id from your data.
SELECT m.movie_id, m.movie_title
FROM movies m
JOIN cast c ON m.movie_id = c.movie_id
WHERE c.actor_id = 1;

-- Query 4: Retrieve user watch history
-- Retrieves all movies a specific user has watched. Example user_id is 42.
SELECT w.watch_date, m.movie_title, w.user_rating
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
WHERE w.user_id = 42;

-- Query 5: Get movie recommendations based on user genre preferences
-- This query returns movies that match the user's preferred genres.
-- Example user_id is 42, replace with an actual user_id from your data.
SELECT DISTINCT m.movie_id, m.movie_title, g.genre_name
FROM movies m
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN genres g ON mg.genre_id = g.genre_id
JOIN user_preferences up ON g.genre_id = up.genre_id
WHERE up.user_id = 42;

-- Query 6: List of actors in a movie
-- Retrieves the list of actors for a specific movie. Example movie_id is 99.
SELECT a.actor_id, a.name
FROM actors a
JOIN cast c ON a.actor_id = c.actor_id
WHERE c.movie_id = 99;

-- Query 7: Retrieve average user rating for each movie
-- Calculates the average rating from users for each movie in the database.
SELECT m.movie_id, m.movie_title, AVG(w.user_rating) AS average_rating
FROM movies m
JOIN watch_history w ON m.movie_id = w.movie_id
GROUP BY m.movie_id, m.movie_title;

-- Query 8: Search movies by title keyword
-- Searches for movies with a title containing the word 'love'.
SELECT movie_id, movie_title
FROM movies
WHERE movie_title LIKE '%love%';

-- Query 9: User ratings versus IMDb ratings
-- Compares user ratings and IMDb ratings for all movies.
SELECT m.movie_id, m.movie_title, AVG(w.user_rating) AS average_user_rating, r.imdb_rating
FROM movies m
LEFT JOIN watch_history w ON m.movie_id = w.movie_id
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.movie_title, r.imdb_rating;

-- Query 10: Find all genres for a movie
-- Lists all genres associated with a specific movie. Example movie_id is 99.
SELECT g.genre_id, g.genre_name
FROM genres g
JOIN movie_genres mg ON g.genre_id = mg.genre_id
WHERE mg.movie_id = 99;