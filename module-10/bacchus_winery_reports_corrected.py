# ---------------------------------------------------------
# Group C
# Wendy Bronson
# Eric Sengvanhpheng
# William Judd
# Luis Cortez
# Martha Guzman
#
# July 22, 2026
# Database Development and Use
# Module 10.1 Milestone #3
# Case Study: Bacchus Winery
#
# Purpose:
# Connect to the Bacchus Winery MySQL database and display
# three business reports that can help management review
# supplier deliveries, wine sales, and employee hours.
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


def display_table(cursor, query, display_title):
    """
    Executes a SQL query and displays the results with
    formatted column headings and aligned output.

    Args:
        cursor: The MySQL cursor used to execute the query.
        query: The SQL query used to retrieve the report data.
        display_title: The title displayed above the report.
    """

    cursor.execute(query)
    rows = cursor.fetchall()
    column_names = [column[0] for column in cursor.description]

    # Convert all values to strings and replace None values with NULL.
    formatted_rows = []

    for row in rows:
        formatted_rows.append(
            [
                "NULL" if value is None else str(value)
                for value in row
            ]
        )

    # Calculate the width needed for each column.
    column_widths = []

    for index, column in enumerate(column_names):
        max_width = len(column)

        for row in formatted_rows:
            max_width = max(max_width, len(row[index]))

        column_widths.append(max_width)

    # Build the formatted table header.
    header = " | ".join(
        column_names[index].ljust(column_widths[index])
        for index in range(len(column_names))
    )

    print("\n" + "=" * len(header))
    print(display_title)
    print("=" * len(header))
    print(header)
    print("-" * len(header))

    # Display a message when the query does not return records.
    if not formatted_rows:
        print("No records were found for this report.")
    else:
        # Display each row using the calculated column widths.
        for row in formatted_rows:
            print(
                " | ".join(
                    row[index].ljust(column_widths[index])
                    for index in range(len(row))
                )
            )

    print()


# =========================================================
# Report 1 - Supplier Delivery Performance
#
# Purpose:
# Summarizes supplier deliveries by month and calculates
# the average number of days deliveries were early or late.
# This report can help management identify suppliers that
# may be experiencing delivery problems.
# =========================================================

def supplier_delivery_monthly_report(cursor):
    """
    Displays monthly supplier delivery totals and the
    average number of days deliveries were early or late.
    """

    query = """
        SELECT
            s.supplier_name,
            MONTH(sd.expected_delivery_date)
                AS delivery_month_number,
            MONTHNAME(sd.expected_delivery_date)
                AS delivery_month,
            COUNT(sd.delivery_id)
                AS total_deliveries,
            ROUND(
                AVG(
                    DATEDIFF(
                        sd.actual_delivery_date,
                        sd.expected_delivery_date
                    )
                ),
                2
            ) AS average_days_early_or_late
        FROM supplier AS s
        INNER JOIN supplier_delivery AS sd
            ON s.supplier_id = sd.supplier_id
        GROUP BY
            s.supplier_name,
            MONTH(sd.expected_delivery_date),
            MONTHNAME(sd.expected_delivery_date)
        ORDER BY
            MONTH(sd.expected_delivery_date),
            average_days_early_or_late DESC;
    """

    display_table(
        cursor,
        query,
        "REPORT 1 - MONTHLY SUPPLIER DELIVERY PERFORMANCE"
    )


# =========================================================
# Report 2 - Wine Sales by Distributor
#
# Purpose:
# Displays wine sales by distributor, including the total
# number of bottles ordered and total sales revenue. This
# report can help management identify which wines are
# selling well and which distributors sell the most wine.
# =========================================================

def wine_sales_by_distributor_report(cursor):
    """
    Displays the total quantity ordered and total sales
    revenue for each wine and distributor.
    """

    query = """
        SELECT
            w.wine_name,
            d.distributor_name,
            SUM(od.quantity_ordered)
                AS total_bottles_ordered,
            ROUND(
                SUM(
                    od.quantity_ordered
                    * od.price_at_purchase
                ),
                2
            ) AS total_sales
        FROM wine AS w
        INNER JOIN order_detail AS od
            ON w.wine_id = od.wine_id
        INNER JOIN distributor_order AS dor
            ON od.order_id = dor.order_id
        INNER JOIN distributor AS d
            ON dor.distributor_id = d.distributor_id
        GROUP BY
            w.wine_id,
            w.wine_name,
            d.distributor_id,
            d.distributor_name
        ORDER BY
            total_bottles_ordered DESC,
            total_sales DESC;
    """

    display_table(
        cursor,
        query,
        "REPORT 2 - WINE SALES BY DISTRIBUTOR"
    )


# =========================================================
# Report 3 - Employee Hours by Quarter
#
# Purpose:
# Displays employee hours for the four most recent quarters
# contained in the employee_time table. This report can help
# management compare workloads and identify changes in
# employee staffing needs.
# =========================================================

def employee_hours_by_quarter_report(cursor):
    """
    Displays each employee's total hours for the four most
    recent quarters stored in the database.
    """

    query = """
        SELECT
            e.employee_id,
            CONCAT(
                e.first_name,
                ' ',
                e.last_name
            ) AS employee_name,
            e.job_title,
            YEAR(et.work_date)
                AS work_year,
            QUARTER(et.work_date)
                AS work_quarter,
            SUM(et.hours_worked)
                AS total_hours
        FROM employee AS e
        INNER JOIN employee_time AS et
            ON e.employee_id = et.employee_id
        INNER JOIN (
            SELECT
                YEAR(work_date) AS report_year,
                QUARTER(work_date) AS report_quarter
            FROM employee_time
            GROUP BY
                YEAR(work_date),
                QUARTER(work_date)
            ORDER BY
                report_year DESC,
                report_quarter DESC
            LIMIT 4
        ) AS recent_quarters
            ON YEAR(et.work_date) = recent_quarters.report_year
            AND QUARTER(et.work_date)
                = recent_quarters.report_quarter
        GROUP BY
            e.employee_id,
            e.first_name,
            e.last_name,
            e.job_title,
            YEAR(et.work_date),
            QUARTER(et.work_date)
        ORDER BY
            work_year DESC,
            work_quarter DESC,
            e.last_name,
            e.first_name;
    """

    display_table(
        cursor,
        query,
        "REPORT 3 - EMPLOYEE HOURS FOR THE LAST FOUR QUARTERS"
    )


def main():
    """
    Controls the main program, runs the three business
    reports, and manages the database connection and cursor.
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

        # Call each business report function.
        supplier_delivery_monthly_report(cursor)
        wine_sales_by_distributor_report(cursor)
        employee_hours_by_quarter_report(cursor)

    except Error as error:
        print("\nA database error occurred.")
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