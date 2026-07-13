"""Module 7.2 Assignment: Movies Table Queries.

Author: William Judd
Date: 7/12/2026
Module 7.2
Course: CSD310 Database Development and Use
Demonstrates SELECT, INSERT, UPDATE, and DELETE operations
"""

import mysql.connector
from mysql.connector import Error


def show_films(cursor, title):
    """Display film information with genre and studio names."""

    cursor.execute(
        """
        SELECT
            film.film_name AS Name,
            film.film_director AS Director,
            genre.genre_name AS Genre,
            studio.studio_name AS Studio
        FROM film
        INNER JOIN genre
            ON film.genre_id = genre.genre_id
        INNER JOIN studio
            ON film.studio_id = studio.studio_id
        ORDER BY film.film_id
        """
    )

    films = cursor.fetchall()

    print(f"\n{title}")
    print("-" * 70)

    for film in films:
        print(
            f"Film Name: {film[0]}\n"
            f"Director: {film[1]}\n"
            f"Genre: {film[2]}\n"
            f"Studio: {film[3]}\n"
        )


def main():
    """Connect to the movies database and perform the required queries."""

    connection = None
    cursor = None

    try:
        connection = mysql.connector.connect(
            user="movies_user",
            password="popcorn",
            host="127.0.0.1",
            database="movies",
            raise_on_warnings=True,
        )

        cursor = connection.cursor()

        # Display the original film records.
        show_films(cursor, "DISPLAYING FILMS")

        # Insert a new film.
        insert_film = (
            "INSERT INTO film "
            "(film_name, film_releaseDate, film_runtime, "
            "film_director, studio_id, genre_id) "
            "VALUES (%s, %s, %s, %s, "
            "(SELECT studio_id FROM studio WHERE studio_name = %s), "
            "(SELECT genre_id FROM genre WHERE genre_name = %s))"
        )

        new_film = (
            "Nope",
            2022,
            130,
            "Jordan Peele",
            "Universal Pictures",
            "SciFi",
        )

        cursor.execute(insert_film, new_film)
        connection.commit()

        show_films(cursor, "DISPLAYING FILMS AFTER INSERT")

        # Update Alien to the Horror genre.
        update_alien = (
            "UPDATE film "
            "SET genre_id = "
            "(SELECT genre_id FROM genre WHERE genre_name = %s) "
            "WHERE film_name = %s"
        )

        cursor.execute(update_alien, ("Horror", "Alien"))
        connection.commit()

        show_films(cursor, "DISPLAYING FILMS AFTER UPDATE")

        # Delete Gladiator.
        delete_gladiator = "DELETE FROM film WHERE film_name = %s"

        cursor.execute(delete_gladiator, ("Gladiator",))
        connection.commit()

        show_films(cursor, "DISPLAYING FILMS AFTER DELETE")

    except Error as error:
        print(f"Database error: {error}")

        if connection and connection.is_connected():
            connection.rollback()

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()
            print("\nMySQL connection closed.")


if __name__ == "__main__":
    main()