"""Module 6.2 Assignment: Movies Table Queries.

Author: William Judd
Course: CSD310 Database Development and Use

This program connects to the MySQL movies database and runs
four SELECT queries against the studio, genre, and film tables.
"""

import mysql.connector
from mysql.connector import errorcode


config = {
    "user": "root",
    "password": "",
    "host": "localhost",
    "database": "movies",
    "raise_on_warnings": True
}


try:
    db = mysql.connector.connect(**config)
    cursor = db.cursor()

    print("\nDISPLAYING Studio RECORDS")
    cursor.execute("SELECT studio_id, studio_name FROM studio")
    studios = cursor.fetchall()

    for studio in studios:
        print("Studio ID: {}".format(studio[0]))
        print("Studio Name: {}\n".format(studio[1]))

    print("\nDISPLAYING Genre RECORDS")
    cursor.execute("SELECT genre_id, genre_name FROM genre")
    genres = cursor.fetchall()

    for genre in genres:
        print("Genre ID: {}".format(genre[0]))
        print("Genre Name: {}\n".format(genre[1]))

    print("\nDISPLAYING Short Film RECORDS")
    cursor.execute("""
        SELECT film_name, film_runtime
        FROM film
        WHERE film_runtime < 120
    """)
    short_films = cursor.fetchall()

    for film in short_films:
        print("Film Name: {}".format(film[0]))
        print("Runtime: {}\n".format(film[1]))

    print("\nDISPLAYING Director RECORDS")
    cursor.execute("""
        SELECT film_name, film_director
        FROM film
        ORDER BY film_director
    """)
    directors = cursor.fetchall()

    for director in directors:
        print("Film Name: {}".format(director[0]))
        print("Director: {}\n".format(director[1]))

except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("The supplied username or password is invalid.")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("The specified database does not exist.")
    else:
        print(err)

finally:
    if "cursor" in locals():
        cursor.close()
    if "db" in locals() and db.is_connected():
        db.close()
