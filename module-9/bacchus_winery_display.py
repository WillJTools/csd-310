# ---------------------------------------------------------
# Group C
# Wendy Bronson
# Eric Sengvanhpheng
# William Judd
# Luis Cortez
# Martha Guzman
#
# July 19th, 2026
# Database Development and Use
# Module 9.1 Milestone #2
# Case Study: Bacchus Winery
#
# Purpose:
# Connect to the Bacchus Winery MySQL database and provide
# the main program structure used to display database tables.
# ---------------------------------------------------------

import mysql.connector
from mysql.connector import Error

from db_config import DATABASE_CONFIG


def create_database_connection():
    """
    Creates and returns a connection to the Bacchus Winery
    MySQL database.

    Returns:
        MySQLConnection: An active database connection.

    Raises:
        Error: If MySQL cannot establish the connection.
    """

    connection = mysql.connector.connect(**DATABASE_CONFIG)

    if connection.is_connected():
        print("Successfully connected to the Bacchus Winery database.")

    return connection


def display_table(cursor, table_name, display_title):
    """
    Displays a database table with formatted column headings 
    and aligned output.
    """

    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()

    column_names = [column[0] for column in cursor.description]

    # create empty list, convert values to strings and replace NULL values
    formatted_rows = []

    for row in rows:
        formatted_rows.append(
            [
                "NULL" if value is None else str(value)
                for value in row
            ]
        )

    # calculate the width needed for each column
    column_widths = []

    for index, column in enumerate(column_names):
        max_width = len(column)

        for row in formatted_rows:
            max_width = max(max_width, len(row[index]))
        
        column_widths.append(max_width)

    # build formatted table header using calculated column widths
    header = " | ".join(
        column_names[i].ljust(column_widths[i])
        for i in range(len(column_names))
    )

    print("\n" + "=" * len(header))
    print(display_title)
    print("=" * len(header))
    
    print(header)
    print("-" * len(header))

    # display each row using the calculated column widths
    for row in formatted_rows:
        print(
            " | ".join(
                row[i].ljust(column_widths[i])
                for i in range(len(row))
            )
        )

    print()


def display_employee_tables(cursor):
    """
    Displays the employee-related tables.
    """
    display_table(cursor, "department", "DEPARTMENT TABLE")
    display_table(cursor, "employee", "EMPLOYEE TABLE")
    display_table(cursor, "employee_time", "EMPLOYEE TIME TABLE")


def display_supplier_tables(cursor):
    """
    Displays the supplier and inventory-related tables.
    """
    display_table(cursor, "supplier", "SUPPLIER TABLE")
    display_table(cursor, "inventory_item", "INVENTORY ITEM TABLE")
    display_table(cursor, "supplier_delivery", "SUPPLIER DELIVERY TABLE")
    display_table(cursor, "supplier_delivery_item", "SUPPLIER DELIVERY ITEM TABLE")
    

def display_wine_tables(cursor):
    """
    Displays the wine-related tables.
    """
    display_table(cursor, "wine", "WINE TABLE")
    display_table(cursor, "wine_production_item", "WINE PRODUCTION ITEM TABLE")


def display_distribution_tables(cursor):
    """
    Displays the distribution-related tables.
    """
    display_table(cursor, "distributor", "DISTRIBUTOR TABLE")
    display_table(cursor, "distributor_order", "DISTRIBUTOR ORDER TABLE")
    display_table(cursor, "order_detail", "ORDER DETAIL TABLE")
    display_table(cursor, "shipment", "SHIPMENT TABLE")


def main():
    """
    Controls the main program and manages the database
    connection and cursor.
    """

    connection = None
    cursor = None

    try:
        connection = create_database_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT DATABASE();")
        selected_database = cursor.fetchone()

        if selected_database:
            print(f"Current database: {selected_database[0]}")

        # Display tables
        display_employee_tables(cursor)
        display_supplier_tables(cursor)
        display_wine_tables(cursor)
        display_distribution_tables(cursor)


    except Error as error:
        print(f"\nUnable to connect to the MySQL database.")
        print(f"MySQL error: {error}")

    finally:
        if cursor is not None:
            cursor.close()
            print("Database cursor closed.")

        if connection is not None and connection.is_connected():
            connection.close()
            print("MySQL connection closed.")


if __name__ == "__main__":
    main()