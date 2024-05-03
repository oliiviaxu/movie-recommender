DROP TABLE IF EXISTS watch_history;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS cast;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS user_preferences;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS actors;

-- SQL Database Creation Script for Movie Recommendation System
-- Table: users
-- Stores user information. Passwords should be stored as hashes.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    salt VARCHAR(8),
    password_hash BINARY(64) NOT NULL, -- Storing hash; assuming SHA256 for hashing
    age INT CHECK (age >= 0) -- Assuming age cannot be negative
);

-- Table: movies
-- Stores basic information about movies.
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_title VARCHAR(255) NOT NULL,
    release_date INT,
    language VARCHAR(50),
    directed_by VARCHAR(255)
);

-- Table: genres
-- Stores different genres of movies.
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE NOT NULL -- Assuming genre names are unique
);

-- Table: actors
-- Stores information about actors.
CREATE TABLE actors (
    actor_id INT AUTO_INCREMENT PRIMARY KEY,
    actor_name VARCHAR(255) NOT NULL
);

-- Table: cast
-- Junction table for the many-to-many relationship between movies and actors.
CREATE TABLE cast (
    movie_id INT,
    actor_id INT,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES actors(actor_id) ON DELETE CASCADE
);

-- Table: movie_genres
-- Junction table for the many-to-many relationship between movies and genres.
CREATE TABLE movie_genres (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

-- Table: watch_history
-- Records the movies watched by users and their ratings.
CREATE TABLE watch_history (
    user_id INT,
    movie_id INT,
    watch_date INT NOT NULL,
    user_rating DECIMAL(3, 1), -- Assuming ratings are from 0.0 to 10.0; adjust if needed
    PRIMARY KEY (user_id, movie_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Table: user_preferences
-- Stores user preferences for genres and actors.
CREATE TABLE user_preferences (
    preference_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    -- Additional fields for preferences can be added here.
    -- Such as genre and actor preferences.
); 

-- Table: ratings
-- Stores user and IMDb ratings for movies.
-- Note that 'user_rating' is stored in 'watch_history'.
CREATE TABLE ratings (
    movie_id INT,
    imdb_rating DECIMAL(4, 2), -- Assuming IMDb ratings are from 0.00 to 10.00; adjust if needed
    PRIMARY KEY (movie_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- 1. AUTO_INCREMENT is used for primary keys to automatically generate unique IDs.
-- 2. All VARCHAR lengths should be reconsidered based on actual data requirements.
-- 3. DECIMAL types are used for ratings to accommodate decimal values; adjust precision and scale as required.
-- 4. ON DELETE CASCADE ensures that related entries are deleted when a referenced entity is deleted.
-- 5. user_preferences table can be expanded with additional fields as needed to store user-specific preferences.
-- 6. It is assumed that each movie has a unique IMDb rating. If there are different ratings (e.g., by different sources), consider adding a source field or restructuring.
-- 7. Additional constraints like CHECKs for ratings, age, etc., can be added based on business rules.