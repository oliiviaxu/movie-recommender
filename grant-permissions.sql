-- Create a new admin user with full privileges on the movie_recommendation_db
CREATE USER 'movie_admin'@'localhost' IDENTIFIED BY 'strongAdminPassword';

CREATE USER 'movie_client'@'localhost' IDENTIFIED BY 'strongClientPassword';

-- Grant full privileges to the movie_admin user for all tables within movie_recommendation_db
GRANT ALL PRIVILEGES ON movie_recommendation_db.* TO 'movie_admin'@'localhost';

-- Grant SELECT privilege to the movie_client user for all tables within movie_recommendation_db
GRANT SELECT ON movie_recommendation_db.* TO 'movie_client'@'localhost';

-- Apply the changes made by the GRANT statements
FLUSH PRIVILEGES;
