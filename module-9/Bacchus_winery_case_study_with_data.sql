-- =========================================================
-- GROUP C
-- Wendy Bronson
-- Eric Sengvanhpheng
-- William Judd
-- Luis Cortez
-- Martha Guzman
--
-- July 2026
-- Database Development and Use
-- Module 9.1 Milestone #2
-- Case Study: Bacchus Winery
--
-- Purpose:
-- Create and populate the Bacchus Winery database according
-- to the finalized entity relationship diagram.
-- =========================================================


-- =========================================================
-- CREATE AND SELECT DATABASE
-- =========================================================

CREATE DATABASE IF NOT EXISTS bacchus_winery;

USE bacchus_winery;


-- =========================================================
-- DROP EXISTING TABLES
-- Child tables must be dropped before parent tables.
-- =========================================================

DROP TABLE IF EXISTS supplier_delivery_item;
DROP TABLE IF EXISTS wine_production_item;
DROP TABLE IF EXISTS shipment;
DROP TABLE IF EXISTS order_detail;
DROP TABLE IF EXISTS employee_time;

DROP TABLE IF EXISTS inventory_item;
DROP TABLE IF EXISTS supplier_delivery;
DROP TABLE IF EXISTS distributor_order;
DROP TABLE IF EXISTS employee;

DROP TABLE IF EXISTS wine;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS distributor;
DROP TABLE IF EXISTS department;


-- =========================================================
-- CREATE DEPARTMENT TABLE
-- =========================================================

CREATE TABLE department (
    department_id      INT          NOT NULL AUTO_INCREMENT,
    department_name    VARCHAR(75)  NOT NULL,

    PRIMARY KEY (department_id),

    CONSTRAINT uq_department_name
        UNIQUE (department_name)
);


-- =========================================================
-- CREATE EMPLOYEE TABLE
-- =========================================================

CREATE TABLE employee (
    employee_id      INT          NOT NULL AUTO_INCREMENT,
    first_name       VARCHAR(75)  NOT NULL,
    last_name        VARCHAR(75)  NOT NULL,
    job_title        VARCHAR(75)  NOT NULL,
    department_id    INT          NOT NULL,

    PRIMARY KEY (employee_id),

    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES department (department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- =========================================================
-- CREATE EMPLOYEE_TIME TABLE
-- Quarter is calculated from work_date and is not stored.
-- =========================================================

CREATE TABLE employee_time (
    time_record_id    INT           NOT NULL AUTO_INCREMENT,
    employee_id       INT           NOT NULL,
    work_date         DATE          NOT NULL,
    hours_worked      DECIMAL(5,2)  NOT NULL,

    PRIMARY KEY (time_record_id),

    CONSTRAINT fk_employee_time_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee (employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_employee_hours
        CHECK (hours_worked >= 0 AND hours_worked <= 24)
);


-- =========================================================
-- CREATE SUPPLIER TABLE
-- =========================================================

CREATE TABLE supplier (
    supplier_id      INT           NOT NULL AUTO_INCREMENT,
    supplier_name    VARCHAR(100)  NOT NULL,
    contact_name     VARCHAR(100)  NOT NULL,
    phone            VARCHAR(20),
    email            VARCHAR(100),

    PRIMARY KEY (supplier_id),

    CONSTRAINT uq_supplier_name
        UNIQUE (supplier_name)
);


-- =========================================================
-- CREATE INVENTORY_ITEM TABLE
-- Tracks bottles, corks, labels, boxes, vats, and tubing.
-- =========================================================

CREATE TABLE inventory_item (
    inventory_item_id    INT            NOT NULL AUTO_INCREMENT,
    supplier_id          INT            NOT NULL,
    item_name            VARCHAR(100)   NOT NULL,
    quantity_on_hand     INT            NOT NULL DEFAULT 0,
    reorder_level        INT            NOT NULL DEFAULT 0,
    unit_cost            DECIMAL(10,2)  NOT NULL,

    PRIMARY KEY (inventory_item_id),

    CONSTRAINT fk_inventory_item_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_inventory_quantity
        CHECK (quantity_on_hand >= 0),

    CONSTRAINT chk_reorder_level
        CHECK (reorder_level >= 0),

    CONSTRAINT chk_inventory_unit_cost
        CHECK (unit_cost >= 0)
);


-- =========================================================
-- CREATE SUPPLIER_DELIVERY TABLE
-- Tracks expected and actual supplier delivery dates.
-- =========================================================

CREATE TABLE supplier_delivery (
    delivery_id               INT          NOT NULL AUTO_INCREMENT,
    supplier_id               INT          NOT NULL,
    expected_delivery_date    DATE         NOT NULL,
    actual_delivery_date      DATE,
    delivery_status           VARCHAR(30)  NOT NULL,

    PRIMARY KEY (delivery_id),

    CONSTRAINT fk_supplier_delivery_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- =========================================================
-- CREATE SUPPLIER_DELIVERY_ITEM TABLE
-- Junction table connecting supplier deliveries and
-- inventory items.
-- =========================================================

CREATE TABLE supplier_delivery_item (
    delivery_id          INT  NOT NULL,
    inventory_item_id    INT  NOT NULL,
    quantity_expected    INT  NOT NULL,
    quantity_received    INT,

    PRIMARY KEY (delivery_id, inventory_item_id),

    CONSTRAINT fk_delivery_item_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES supplier_delivery (delivery_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_delivery_item_inventory
        FOREIGN KEY (inventory_item_id)
        REFERENCES inventory_item (inventory_item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_quantity_expected
        CHECK (quantity_expected > 0),

    CONSTRAINT chk_quantity_received
        CHECK (
            quantity_received IS NULL
            OR quantity_received >= 0
        )
);


-- =========================================================
-- CREATE WINE TABLE
-- The case study identifies four wines.
-- =========================================================

CREATE TABLE wine (
    wine_id          INT            NOT NULL AUTO_INCREMENT,
    wine_name        VARCHAR(75)    NOT NULL,
    wine_type        VARCHAR(30)    NOT NULL,
    vintage_year     YEAR           NOT NULL,
    sales_price      DECIMAL(10,2)  NOT NULL,

    PRIMARY KEY (wine_id),

    CONSTRAINT uq_wine_name_vintage
        UNIQUE (wine_name, vintage_year),

    CONSTRAINT chk_wine_sales_price
        CHECK (sales_price >= 0)
);


-- =========================================================
-- CREATE WINE_PRODUCTION_ITEM TABLE
-- Junction table connecting wines to production and
-- packaging inventory items.
-- =========================================================

CREATE TABLE wine_production_item (
    wine_id              INT            NOT NULL,
    inventory_item_id    INT            NOT NULL,
    quantity_required    DECIMAL(10,2)  NOT NULL,

    PRIMARY KEY (wine_id, inventory_item_id),

    CONSTRAINT fk_production_item_wine
        FOREIGN KEY (wine_id)
        REFERENCES wine (wine_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_production_item_inventory
        FOREIGN KEY (inventory_item_id)
        REFERENCES inventory_item (inventory_item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_quantity_required
        CHECK (quantity_required > 0)
);


-- =========================================================
-- CREATE DISTRIBUTOR TABLE
-- =========================================================

CREATE TABLE distributor (
    distributor_id      INT           NOT NULL AUTO_INCREMENT,
    distributor_name    VARCHAR(100)  NOT NULL,
    contact_name        VARCHAR(100)  NOT NULL,
    phone               VARCHAR(20),
    email               VARCHAR(100),

    PRIMARY KEY (distributor_id),

    CONSTRAINT uq_distributor_name
        UNIQUE (distributor_name)
);


-- =========================================================
-- CREATE DISTRIBUTOR_ORDER TABLE
-- =========================================================

CREATE TABLE distributor_order (
    order_id          INT          NOT NULL AUTO_INCREMENT,
    distributor_id    INT          NOT NULL,
    order_date        DATE         NOT NULL,
    order_status      VARCHAR(30)  NOT NULL,

    PRIMARY KEY (order_id),

    CONSTRAINT fk_distributor_order_distributor
        FOREIGN KEY (distributor_id)
        REFERENCES distributor (distributor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- =========================================================
-- CREATE ORDER_DETAIL TABLE
-- Junction table connecting distributor orders and wines.
-- =========================================================

CREATE TABLE order_detail (
    order_detail_id       INT            NOT NULL AUTO_INCREMENT,
    order_id              INT            NOT NULL,
    wine_id               INT            NOT NULL,
    quantity_ordered      INT            NOT NULL,
    price_at_purchase     DECIMAL(10,2)  NOT NULL,

    PRIMARY KEY (order_detail_id),

    CONSTRAINT fk_order_detail_order
        FOREIGN KEY (order_id)
        REFERENCES distributor_order (order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_order_detail_wine
        FOREIGN KEY (wine_id)
        REFERENCES wine (wine_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_order_wine
        UNIQUE (order_id, wine_id),

    CONSTRAINT chk_quantity_ordered
        CHECK (quantity_ordered > 0),

    CONSTRAINT chk_price_at_purchase
        CHECK (price_at_purchase >= 0)
);


-- =========================================================
-- CREATE SHIPMENT TABLE
-- Shipment date may be NULL until an order is shipped.
-- =========================================================

CREATE TABLE shipment (
    shipment_id               INT           NOT NULL AUTO_INCREMENT,
    order_id                  INT           NOT NULL,
    tracking_number           VARCHAR(75),
    carrier_name              VARCHAR(75),
    shipment_date             DATE,
    expected_delivery_date    DATE,
    actual_delivery_date      DATE,
    shipment_status           VARCHAR(30)   NOT NULL,

    PRIMARY KEY (shipment_id),

    CONSTRAINT uq_tracking_number
        UNIQUE (tracking_number),

    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id)
        REFERENCES distributor_order (order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- =========================================================
-- POPULATE DEPARTMENT
-- Four departments are identified in the case study.
-- =========================================================

INSERT INTO department (department_name)
VALUES
    ('Finance'),
    ('Marketing'),
    ('Production'),
    ('Distribution');


-- =========================================================
-- POPULATE EMPLOYEE
-- Includes the five named employees and one production
-- employee to meet the six-record requirement.
-- =========================================================

INSERT INTO employee
    (first_name, last_name, job_title, department_id)
VALUES
    ('Janet', 'Collins', 'Finance Manager', 1),
    ('Roz', 'Murphy', 'Marketing Manager', 2),
    ('Bob', 'Ulrich', 'Marketing Assistant', 2),
    ('Henry', 'Doyle', 'Production Manager', 3),
    ('Maria', 'Costanza', 'Distribution Manager', 4),
    ('Alex', 'Turner', 'Production Employee', 3);


-- =========================================================
-- POPULATE EMPLOYEE_TIME
-- Dates are spread across four quarters.
-- Quarter is calculated from work_date.
-- =========================================================

INSERT INTO employee_time
    (employee_id, work_date, hours_worked)
VALUES
    -- Third quarter 2025
    (1, '2025-08-15', 8.00),
    (2, '2025-08-15', 8.00),
    (3, '2025-08-15', 7.50),
    (4, '2025-08-15', 9.00),
    (5, '2025-08-15', 8.00),
    (6, '2025-08-15', 8.50),

    -- Fourth quarter 2025
    (1, '2025-11-14', 8.00),
    (2, '2025-11-14', 7.75),
    (3, '2025-11-14', 8.00),
    (4, '2025-11-14', 9.25),
    (5, '2025-11-14', 8.25),
    (6, '2025-11-14', 8.00),

    -- First quarter 2026
    (1, '2026-02-13', 8.00),
    (2, '2026-02-13', 8.25),
    (3, '2026-02-13', 7.75),
    (4, '2026-02-13', 9.00),
    (5, '2026-02-13', 8.00),
    (6, '2026-02-13', 8.50),

    -- Second quarter 2026
    (1, '2026-05-15', 8.00),
    (2, '2026-05-15', 8.00),
    (3, '2026-05-15', 7.50),
    (4, '2026-05-15', 9.25),
    (5, '2026-05-15', 8.25),
    (6, '2026-05-15', 8.00);


-- =========================================================
-- POPULATE SUPPLIER
-- Three suppliers are identified in the case study.
-- =========================================================

INSERT INTO supplier
    (supplier_name, contact_name, phone, email)
VALUES
    (
        'Bottle and Cork Supply Company',
        'Aaron Mitchell',
        '402-555-0101',
        'aaron@bottlecork.com'
    ),
    (
        'Label and Box Packaging Company',
        'Samantha Reed',
        '402-555-0102',
        'samantha@labelbox.com'
    ),
    (
        'Winery Equipment Supply Company',
        'Thomas Walker',
        '402-555-0103',
        'thomas@wineryequipment.com'
    );


-- =========================================================
-- POPULATE INVENTORY_ITEM
-- Matches the supplies listed in the case study.
-- =========================================================

INSERT INTO inventory_item
    (
        supplier_id,
        item_name,
        quantity_on_hand,
        reorder_level,
        unit_cost
    )
VALUES
    (1, '750 ml Wine Bottles', 1200, 500, 1.25),
    (1, 'Natural Wine Corks', 1800, 600, 0.35),
    (2, 'Wine Labels', 900, 300, 0.18),
    (2, 'Wine Shipping Boxes', 350, 150, 2.50),
    (3, 'Wine Production Vats', 8, 2, 2500.00),
    (3, 'Production Tubing', 500, 150, 3.25);


-- =========================================================
-- POPULATE SUPPLIER_DELIVERY
-- Includes on-time, late, partial, and scheduled deliveries.
-- =========================================================

INSERT INTO supplier_delivery
    (
        supplier_id,
        expected_delivery_date,
        actual_delivery_date,
        delivery_status
    )
VALUES
    (1, '2026-01-10', '2026-01-10', 'On Time'),
    (1, '2026-02-12', '2026-02-14', 'Late and Partial'),
    (2, '2026-03-08', '2026-03-08', 'On Time'),
    (2, '2026-04-15', NULL, 'Scheduled'),
    (3, '2026-05-10', '2026-05-12', 'Late'),
    (3, '2026-06-18', NULL, 'Scheduled');


-- =========================================================
-- POPULATE SUPPLIER_DELIVERY_ITEM
-- =========================================================

INSERT INTO supplier_delivery_item
    (
        delivery_id,
        inventory_item_id,
        quantity_expected,
        quantity_received
    )
VALUES
    (1, 1, 500, 500),
    (2, 2, 750, 725),
    (3, 3, 400, 400),
    (4, 4, 200, NULL),
    (5, 5, 2, 2),
    (6, 6, 250, NULL);


-- =========================================================
-- POPULATE WINE
-- Only the four wines identified in the case study.
-- =========================================================

INSERT INTO wine
    (wine_name, wine_type, vintage_year, sales_price)
VALUES
    ('Bacchus Merlot', 'Merlot', 2021, 32.00),
    ('Bacchus Cabernet', 'Cabernet', 2020, 38.00),
    ('Bacchus Chablis', 'Chablis', 2022, 27.00),
    ('Bacchus Chardonnay', 'Chardonnay', 2022, 28.00);


-- =========================================================
-- POPULATE WINE_PRODUCTION_ITEM
-- Tracks consumable supplies used to package each wine.
-- =========================================================

INSERT INTO wine_production_item
    (wine_id, inventory_item_id, quantity_required)
VALUES
    -- Merlot
    (1, 1, 1.00),
    (1, 2, 1.00),
    (1, 3, 1.00),
    (1, 4, 0.08),

    -- Cabernet
    (2, 1, 1.00),
    (2, 2, 1.00),
    (2, 3, 1.00),
    (2, 4, 0.08),

    -- Chablis
    (3, 1, 1.00),
    (3, 2, 1.00),
    (3, 3, 1.00),
    (3, 4, 0.08),

    -- Chardonnay
    (4, 1, 1.00),
    (4, 2, 1.00),
    (4, 3, 1.00),
    (4, 4, 0.08);


-- =========================================================
-- POPULATE DISTRIBUTOR
-- =========================================================

INSERT INTO distributor
    (
        distributor_name,
        contact_name,
        phone,
        email
    )
VALUES
    (
        'Midwest Wine Distribution',
        'Laura Simmons',
        '402-555-0201',
        'laura@midwestwine.com'
    ),
    (
        'Great Plains Beverage',
        'Michael Turner',
        '402-555-0202',
        'michael@greatplains.com'
    ),
    (
        'Heartland Fine Wines',
        'Angela Morris',
        '402-555-0203',
        'angela@heartlandwines.com'
    ),
    (
        'River City Distributors',
        'Daniel Foster',
        '402-555-0204',
        'daniel@rivercity.com'
    ),
    (
        'Prairie State Wine Group',
        'Nicole Bennett',
        '402-555-0205',
        'nicole@prairiestate.com'
    ),
    (
        'Central Cellars Distribution',
        'Kevin Ramirez',
        '402-555-0206',
        'kevin@centralcellars.com'
    );


-- =========================================================
-- POPULATE DISTRIBUTOR_ORDER
-- =========================================================

INSERT INTO distributor_order
    (distributor_id, order_date, order_status)
VALUES
    (1, '2026-01-15', 'Delivered'),
    (2, '2026-02-10', 'Delivered'),
    (3, '2026-03-05', 'Delivered'),
    (4, '2026-04-12', 'Shipped'),
    (5, '2026-05-18', 'Processing'),
    (6, '2026-06-20', 'Pending'),
    (1, '2026-06-24', 'Shipped'),
    (3, '2026-06-28', 'Processing');


-- =========================================================
-- POPULATE ORDER_DETAIL
-- Some orders contain more than one wine.
-- =========================================================

INSERT INTO order_detail
    (
        order_id,
        wine_id,
        quantity_ordered,
        price_at_purchase
    )
VALUES
    -- Order 1
    (1, 1, 24, 32.00),
    (1, 2, 18, 38.00),

    -- Order 2
    (2, 3, 30, 27.00),
    (2, 4, 24, 28.00),

    -- Order 3
    (3, 1, 36, 32.00),

    -- Order 4
    (4, 2, 20, 38.00),
    (4, 3, 18, 27.00),

    -- Order 5
    (5, 4, 36, 28.00),

    -- Order 6
    (6, 1, 24, 32.00),

    -- Order 7
    (7, 2, 30, 38.00),
    (7, 4, 20, 28.00),

    -- Order 8
    (8, 3, 24, 27.00);


-- =========================================================
-- POPULATE SHIPMENT
-- Orders that have not shipped may have NULL shipment data.
-- =========================================================

INSERT INTO shipment
    (
        order_id,
        tracking_number,
        carrier_name,
        shipment_date,
        expected_delivery_date,
        actual_delivery_date,
        shipment_status
    )
VALUES
    (
        1,
        'UPS-BW-1001',
        'UPS',
        '2026-01-16',
        '2026-01-19',
        '2026-01-19',
        'Delivered'
    ),
    (
        2,
        'FDX-BW-1002',
        'FedEx',
        '2026-02-11',
        '2026-02-14',
        '2026-02-14',
        'Delivered'
    ),
    (
        3,
        'UPS-BW-1003',
        'UPS',
        '2026-03-06',
        '2026-03-09',
        '2026-03-10',
        'Delivered Late'
    ),
    (
        4,
        'FDX-BW-1004',
        'FedEx',
        '2026-04-13',
        '2026-04-16',
        NULL,
        'In Transit'
    ),
    (
        7,
        'UPS-BW-1007',
        'UPS',
        '2026-06-25',
        '2026-06-28',
        NULL,
        'In Transit'
    ),
    (
        8,
        NULL,
        NULL,
        NULL,
        '2026-07-02',
        NULL,
        'Preparing'
    );


-- =========================================================
-- VERIFY TABLE CREATION
-- =========================================================

SHOW TABLES;


-- =========================================================
-- VERIFY RECORD COUNTS
-- =========================================================

SELECT COUNT(*) AS department_count
FROM department;

SELECT COUNT(*) AS employee_count
FROM employee;

SELECT COUNT(*) AS employee_time_count
FROM employee_time;

SELECT COUNT(*) AS supplier_count
FROM supplier;

SELECT COUNT(*) AS inventory_item_count
FROM inventory_item;

SELECT COUNT(*) AS supplier_delivery_count
FROM supplier_delivery;

SELECT COUNT(*) AS supplier_delivery_item_count
FROM supplier_delivery_item;

SELECT COUNT(*) AS wine_count
FROM wine;

SELECT COUNT(*) AS wine_production_item_count
FROM wine_production_item;

SELECT COUNT(*) AS distributor_count
FROM distributor;

SELECT COUNT(*) AS distributor_order_count
FROM distributor_order;

SELECT COUNT(*) AS order_detail_count
FROM order_detail;

SELECT COUNT(*) AS shipment_count
FROM shipment;


-- =========================================================
-- DISPLAY ALL TABLE DATA
-- These statements help verify the records before the
-- Python program is created.
-- =========================================================

SELECT * FROM department;
SELECT * FROM employee;
SELECT * FROM employee_time;
SELECT * FROM supplier;
SELECT * FROM inventory_item;
SELECT * FROM supplier_delivery;
SELECT * FROM supplier_delivery_item;
SELECT * FROM wine;
SELECT * FROM wine_production_item;
SELECT * FROM distributor;
SELECT * FROM distributor_order;
SELECT * FROM order_detail;
SELECT * FROM shipment;


-- =========================================================
-- OPTIONAL REPORT TEST 1
-- SUPPLIER DELIVERY PERFORMANCE
-- =========================================================

SELECT
    s.supplier_name,
    sd.delivery_id,
    sd.expected_delivery_date,
    sd.actual_delivery_date,
    sd.delivery_status,
    DATEDIFF(
        sd.actual_delivery_date,
        sd.expected_delivery_date
    ) AS days_late
FROM supplier AS s
JOIN supplier_delivery AS sd
    ON s.supplier_id = sd.supplier_id
ORDER BY sd.expected_delivery_date;


-- =========================================================
-- OPTIONAL REPORT TEST 2
-- WINE SALES TOTALS
-- =========================================================

SELECT
    w.wine_name,
    SUM(od.quantity_ordered) AS total_quantity_ordered,
    SUM(
        od.quantity_ordered * od.price_at_purchase
    ) AS total_sales
FROM wine AS w
JOIN order_detail AS od
    ON w.wine_id = od.wine_id
GROUP BY
    w.wine_id,
    w.wine_name
ORDER BY total_quantity_ordered DESC;


-- =========================================================
-- OPTIONAL REPORT TEST 3
-- EMPLOYEE HOURS BY QUARTER
-- =========================================================

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    YEAR(et.work_date) AS work_year,
    QUARTER(et.work_date) AS work_quarter,
    SUM(et.hours_worked) AS total_hours
FROM employee AS e
JOIN employee_time AS et
    ON e.employee_id = et.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    YEAR(et.work_date),
    QUARTER(et.work_date)
ORDER BY
    e.employee_id,
    work_year,
    work_quarter;