Welcome to our Movie Recommendation Database! This application was designed 
and written by Ishaan Mantripragada, Olivia Xu, and Rohan Jha for our final 
project in Caltech's CS 121 class. We aimed to create a system that provides 
personalized movie recommendations, allowing users to explore a diverse 
collection of movies, search for movies based on specific preferences, as 
well as rate movies. 

Dataset:
We use a dataset of IMBD movie ratings from Kaggle to load our database. 
Here is the link to the dataset: 
https://www.kaggle.com/datasets/thedevastator/imdb-movie-ratings-dataset. 

Creating the database:
To use our application, you must first create the database which we call 
'movie_recommendation_db'. To do this, first create a MySQL server and use the 
following commands:

CREATE DATABASE movie_recommendation_db;
USE movie_recommendation_db;

Then, source in the following files using the following commands:

source ddl.sql;
source load-data.sql;
source grant-permissions.sql;
source queries.sql;
source setup_routine.sql;
source setup-passwords.sql;

After doing this, open a separate terminal window and run the following command:

python3 app.py

Now you are ready to use our application! Enjoy!