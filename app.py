import sys
import mysql.connector
from mysql.connector import errorcode

# Global variable for debug mode
DEBUG = True

# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """
    Establishes and returns a connection to the database.
    Exits the application on failure.
    """
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='movie_admin',  # Use the client user for regular application use
            password='strongAdminPassword',
            database='movie_recommendation_db'
        )
        print('Successfully connected to the database.')
        return conn
    except mysql.connector.Error as err:
        if DEBUG:
            print(f"Error: {err}", file=sys.stderr)
        sys.exit(1)

# ----------------------------------------------------------------------
# User Authentication and Registration
# ----------------------------------------------------------------------
def register_user(conn):
    """
    Registers a new user by inserting their information into the users table.
    """
    username = input("Enter your desired username: ")
    password = input("Enter your password: ")
    age = input("Enter your age: ")
    print("\n")
    cursor = conn.cursor()
    try:
        cursor.callproc('sp_add_user', [username, password, int(age)])
        conn.commit()
        print("Registration successful. You can now log in.")
    except mysql.connector.Error as err:
        if DEBUG:
            print(f"Registration failed: {err}", file=sys.stderr)
        else:
            print("Registration failed. Please try again.", file=sys.stderr)

def login_user(conn):
    """
    Authenticates a user by checking their credentials against the database.
    """
    username = input("Username: ")
    password = input("Password: ")
    print("\n")
    cursor = conn.cursor()
    try:
        # Adjusted to call the authenticate function
        cursor.execute("SELECT authenticate(%s, %s) AS auth_result", (username, password))
        result = cursor.fetchone()
        auth_result = result[0] if result else 0  # Retrieve the function result



        if auth_result:
            print("Login successful!")
            cursor.execute("SELECT user_id FROM users WHERE username = %s", (username,))
            user_id = cursor.fetchone()
            return True, user_id[0]
        else:
            print("Login failed. Please check your username and password.")
            return False, 0
    except mysql.connector.Error as err:
        if DEBUG:
            print(f"Login error: {err}", file=sys.stderr)
        return False


# ----------------------------------------------------------------------
# Application Functionality
# ----------------------------------------------------------------------
def browse_movies(conn):
    """
    Displays a list of the top 25 movies rated by IMDb from the database, based on the provided DDL.
    """
    cursor = conn.cursor()
    # Join movies with ratings on movie_id and order by IMDb rating in descending order, limit to top 25
    cursor.execute("""
        SELECT m.movie_id, m.movie_title, m.release_date, r.imdb_rating
        FROM movies m
        JOIN ratings r ON m.movie_id = r.movie_id
        ORDER BY r.imdb_rating DESC
        LIMIT 25
    """)
    movies = cursor.fetchall()
    print("\n")

    if movies:
        print("Top 25 Movies by IMDb Rating:")
        for movie in movies:
            # Including IMDb rating in the output
            print(f"{movie[0]}: {movie[1]} -- Release Year: {movie[2]}, IMDb Rating: {movie[3]}")
        print("\n")
    else:
        print("No movies found.")
        print("\n")


def rate_movie(conn, user_id):
    """
    Allows a user to rate a movie, updating the watch_history table.
    """
    movie_id = input("Enter the movie ID you want to rate: ")
    rating = float(input("Enter your rating for the movie (0.0 to 10.0): "))
    if(rating < 0 or rating > 10.0):
        rating = float(input("Please enter a valid rating (0.0 to 10.0): "))
    rating = str(rating)
    watch_date = input("When did you watch this movie? (YYYY): ")

    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("INSERT INTO watch_history (user_id, movie_id, watch_date, user_rating) VALUES (%s, %s, %s, %s) ON DUPLICATE KEY UPDATE user_rating = %s", (user_id, movie_id, watch_date, rating, rating))
        conn.commit()
        print("Your rating has been recorded.")
        print("\n")
    except mysql.connector.Error as err:
        if DEBUG:
            print(f"Rating failed: {err}", file=sys.stderr)
            print("\n")
        else:
            print("Failed to record your rating. Please try again.", file=sys.stderr)
            print("\n")

def browse_movies_by_genre(conn):
    """
    Prompts for a genre, then displays a list of movies from the database
    filtered by that genre and ordered by IMDb rating.
    """
    # Prompt the user for the genre name
    genre_name = input("Enter the genre: ")
    print("\n")
    
    cursor = conn.cursor()
    cursor.execute("""
        SELECT m.movie_id, m.movie_title, r.imdb_rating, g.genre_name
        FROM movies m
        JOIN movie_genres mg ON m.movie_id = mg.movie_id
        JOIN genres g ON mg.genre_id = g.genre_id
        JOIN ratings r ON m.movie_id = r.movie_id
        WHERE g.genre_name = %s
        ORDER BY r.imdb_rating DESC
        LIMIT 10
    """, (genre_name,))
    movies = cursor.fetchall()

    if movies:
        print(f"Movies in the genre '{genre_name}':")
        for movie in movies:
            print(f"{movie[0]}: {movie[1]} -- IMDb Rating: {movie[2]}")
        print("\n")
    else:
        print(f"No movies found in the genre '{genre_name}'.")
        print("\n")

def browse_movies_by_actor(conn):
    """
    Prompts for an actor's name, then displays a list of movies from the database
    that the actor has been a part of, ordered by release date.
    """
    # Prompt the user for the actor's name
    actor_name = input("Enter the actor's name: ")
    print("\n")

    cursor = conn.cursor()
    # Use the correct column name 'actor_name' in the WHERE clause
    cursor.execute("""
        SELECT m.movie_id, m.movie_title, m.release_date
        FROM movies m
        JOIN cast ON m.movie_id = cast.movie_id
        JOIN actors a ON cast.actor_id = a.actor_id
        WHERE a.actor_name = %s
        ORDER BY m.release_date
    """, (actor_name,))

    movies = cursor.fetchall()

    if movies:
        print(f"Movies featuring {actor_name}:")
        for movie in movies:
            print(f"{movie[1]} (Release Year: {movie[2]})")
        print("\n")
    else:
        print(f"No movies found with the actor {actor_name}.")
        print("\n")



def browse_movies_by_director(conn):
    """
    Prompts for a director's name, then displays a list of movies from the database
    that were directed by that director, ordered by release date.
    """
    # Prompt the user for the director's name
    director_name = input("Enter the director's name: ")
    print("\n")

    cursor = conn.cursor()
    cursor.execute("""
        SELECT movie_id, movie_title, release_date
        FROM movies
        WHERE directed_by = %s
        ORDER BY release_date
        LIMIT 10
    """, (director_name,))

    movies = cursor.fetchall()

    if movies:
        print(f"Movies directed by {director_name}:")
        for movie in movies:
            release_date = movie[2] if movie[2] else "Unknown release date"
            print(f"{movie[1]} (Release Date: {release_date})")
        print("\n")
    else:
        print(f"No movies found for the director {director_name}.")
        print("\n")


def show_user_watch_history(conn, user_id):
    """
    Displays the watch history for a given user ID, including the username.
    """
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT username FROM users WHERE user_id = %s", (user_id,))
    user_result = cursor.fetchone()
    if not user_result:
        print(f"No user found with ID {user_id}.")
        print("\n")
        return

    username = user_result['username']
    
    # Now, get the watch history
    query = """
        SELECT m.movie_title, wh.watch_date, wh.user_rating
        FROM watch_history wh
        JOIN movies m ON wh.movie_id = m.movie_id
        WHERE wh.user_id = %s
        ORDER BY wh.user_rating DESC;
        LIMIT 25
    """
    cursor.execute(query, (user_id,))
    watch_history = cursor.fetchall()

    if watch_history:
        print(f"Watch history for {username}:")
        for movie in watch_history:
            print(f"Movie: {movie['movie_title']}, Date Watched: {movie['watch_date']}, Rating: {movie['user_rating']}")
        print("\n")
    else:
        print(f"No watch history found for {username}.")
        print("\n")


def get_user_recommendations(conn, user_id):
    """
    Recommends movies to the user based on their watch history.
    If the watch history is empty, prompts the user to rate some movies.
    """
    print("\n")
    cursor = conn.cursor()
    
    # Get the user's watch history
    cursor.execute("""
        SELECT mh.movie_id, g.genre_id, g.genre_name
        FROM watch_history mh
        JOIN movie_genres mg ON mh.movie_id = mg.movie_id
        JOIN genres g ON mg.genre_id = g.genre_id
        WHERE mh.user_id = %s
    """, (user_id,))
    
    watched_movies = cursor.fetchall()
    
    if not watched_movies:
        print("It seems as though your watch history is empty. Rate some movies and we can recommend some new ones!\n")
        return
    
    # Count the genres in the watch history
    genre_count = {}
    for movie in watched_movies:
        genre_count[movie[2]] = genre_count.get(movie[2], 0) + 1
    
    # Find the most watched genre
    most_watched_genre = max(genre_count, key=genre_count.get)
    
    # Recommend movies from the most watched genre that the user hasn't watched yet
    cursor.execute("""
        SELECT m.movie_id, m.movie_title, r.imdb_rating
        FROM movies m
        JOIN movie_genres mg ON m.movie_id = mg.movie_id
        JOIN genres g ON mg.genre_id = g.genre_id
        LEFT JOIN ratings r ON m.movie_id = r.movie_id
        WHERE g.genre_name = %s AND m.movie_id NOT IN (
            SELECT movie_id FROM watch_history WHERE user_id = %s
        )
        ORDER BY r.imdb_rating DESC
        LIMIT 10
    """, (most_watched_genre, user_id))
    
    recommended_movies = cursor.fetchall()
    print("\n")
    if recommended_movies:
        print(f"Based on your watch history, you might like these movies in the {most_watched_genre} genre:")
        for movie in recommended_movies:
            print(f"{movie[1]} -- IMDb Rating: {movie[2]}")
        print("\n")
    else:
        print("We couldn't find any new recommendations in your favorite genre right now.")
        print("\n")



# ----------------------------------------------------------------------
# Command-Line Interface
# ----------------------------------------------------------------------
def show_menu():
    """
    Shows the main menu of the application and handles user input.
    """
    conn = get_conn()
    logged_in = False
    user_id = None
    username = None

    while True:
        if not logged_in:
            print("1. Login\n2. Register\n3. Browse Movies\n4. Quit")
            choice = input("Choose an option: ")

            if choice == '1':
                logged_in, user_id = login_user(conn)
            elif choice == '2':
                register_user(conn)
            elif choice == '3':
                browse_movies(conn)
            elif choice == '4':
                break
            else:
                print("Invalid choice. Please try again.")
        else:
            print("1. Browse Movies\n2. Rate a Movie\n3. Get Recommendations\n4. Browse by Genre\n5. Browse by Actor\n6. Browse by Director\n7. See Watch History\n8. Logout")
            choice = input("Choose an option: ")

            if choice == '1':
                browse_movies(conn)
            elif choice == '2':
                rate_movie(conn, user_id)
            elif choice == '3':
                get_user_recommendations(conn, user_id)
            elif choice == '4':
                browse_movies_by_genre(conn)
            elif choice == '5':
                browse_movies_by_actor(conn)
            elif choice == '6':
                browse_movies_by_director(conn)
            elif choice == '7':
                show_user_watch_history(conn, user_id)
            elif choice == '8':
                print("See you again soon!\n")
                logged_in = False
                user_id = None
            else:
                print("Invalid choice. Please try again.")

if __name__ == "__main__":
    show_menu()