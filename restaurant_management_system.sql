-- Restaurant Management System 

-- 1. DROP existing tables (if any) to start from a clean slate
DROP TABLE IF EXISTS OrderItems CASCADE;
DROP TABLE IF EXISTS AppliedPromotion CASCADE;
DROP TABLE IF EXISTS Promotion CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Delivery CASCADE;
DROP TABLE IF EXISTS DeliveryDriver CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS MenuItem CASCADE;
DROP TABLE IF EXISTS Restaurant CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;

-- 2. CREATE TABLES

-- 2.1 Customer: holds customer info
CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,       -- Unique customer ID
    Name VARCHAR(100) NOT NULL,          -- Customer name
    Email VARCHAR(100) UNIQUE NOT NULL,  -- Unique email address
    Phone VARCHAR(15) UNIQUE NOT NULL,   -- Unique phone number
    Address VARCHAR(255) NOT NULL        -- Delivery address
);

-- 2.2 Restaurant: lists partner restaurants
CREATE TABLE Restaurant (
    RestaurantID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Phone VARCHAR(15) NOT NULL
);

-- 2.3 MenuItem: items offered by each restaurant
CREATE TABLE MenuItem (
    ItemID SERIAL,                       -- Auto-incrementing item ID
    RestaurantID INT NOT NULL,           -- Link to Restaurant
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Price NUMERIC(10,2) NOT NULL CHECK (Price >= 0),  -- Non-negative price
    PRIMARY KEY (ItemID, RestaurantID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

-- 2.4 Orders: records customer orders
CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,             -- Link to Customer
    OrderDate DATE DEFAULT CURRENT_DATE,
    Status VARCHAR(20) CHECK (Status IN ('Pending','Preparing','Out for Delivery','Completed','Canceled')),
    TotalPrice NUMERIC(10,2) NOT NULL CHECK (TotalPrice >= 0),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- 2.5 Payment: tracks payments for orders
CREATE TABLE Payment (
    PaymentID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL,                -- Link to Orders
    PaymentMethod VARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('Card','PayPal','Apple Pay','Other')),
    Amount NUMERIC(10,2) NOT NULL CHECK (Amount >= 0),
    Status VARCHAR(20) CHECK (Status IN ('Success','Failed','Refunded')),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- 2.6 DeliveryDriver: delivery personnel info
CREATE TABLE DeliveryDriver (
    DriverID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    VehicleType VARCHAR(50)
);

-- 2.7 Delivery: logs pickups and drop-offs
CREATE TABLE Delivery (
    DeliveryID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL,                -- Link to Orders
    DriverID INT NOT NULL,               -- Link to Driver
    PickupTime TIMESTAMP,
    DeliveryTime TIMESTAMP,
    Status VARCHAR(20) CHECK (Status IN ('In Transit','Delivered','Failed')),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (DriverID) REFERENCES DeliveryDriver(DriverID)
);

-- 2.8 Review: stores ratings and comments
CREATE TABLE Review (
    ReviewID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    RestaurantID INT NOT NULL,
    DriverID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),  -- 1 to 5
    ReviewComment TEXT,
    ReviewDate DATE DEFAULT CURRENT_DATE,
    ReviewType VARCHAR(20) CHECK (ReviewType IN ('R','D')),  -- R=Restaurant, D=Driver
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID),
    FOREIGN KEY (DriverID) REFERENCES DeliveryDriver(DriverID)
);

-- 2.9 Promotion: discount campaigns
CREATE TABLE Promotion (
    PromoID SERIAL PRIMARY KEY,
    RestaurantID INT NOT NULL,
    DiscountPercentage NUMERIC(5,2) CHECK (DiscountPercentage BETWEEN 0 AND 100),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

-- 2.10 AppliedPromotion: links customers to promos
CREATE TABLE AppliedPromotion (
    CustomerID INT NOT NULL,
    PromoID INT NOT NULL,
    DateApplied DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (CustomerID, PromoID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

-- 2.11 OrderItems: breakdown of items per order
CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    RestaurantID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, ItemID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID,RestaurantID) REFERENCES MenuItem(ItemID,RestaurantID)
);

-- 3. INSERT sample data into main tables

-- 3.1 Customers
INSERT INTO Customer (Name,Email,Phone,Address) VALUES
('LeBron James','lebron.james@example.com','1234567890','123 Main St'),
('Scarlett Johansson','scarlett.johansson@example.com','2345678901','456 Elm St'),
('Stephen Curry','stephen.curry@example.com','3456789012','789 Oak St'),
('Tom Hanks','tom.hanks@example.com','4567890123','321 Pine St'),
('Kevin Durant','kevin.durant@example.com','5678901234','654 Maple St'),
('Angelina Jolie','angelina.jolie@example.com','6789012345','987 Cedar St'),
('Kobe Bryant','kobe.bryant@example.com','7890123456','135 Birch St'),
('Leonardo DiCaprio','leonardo.dicaprio@example.com','8901234567','246 Walnut St'),
('Giannis Antetokounmpo','giannis.antetokounmpo@example.com','9012345678','369 Cherry St'),
('Jennifer Lawrence','jennifer.lawrence@example.com','0123456789','482 Spruce St');

-- 3.2 Restaurants
INSERT INTO Restaurant (Name,Address,Phone) VALUES
('McDonalds','123 Food St','1112223333'),
('Burger King','456 Fast Ln','2223334444'),
('Taco Bell','789 Taco Rd','3334445555'),
('Subway','321 Sushi Ave','4445556666'),
('Dominos Pizza','654 Pasta Blvd','5556667777'),
('KFC','987 Steak Rd','6667778888'),
('Starbucks','135 Vegan Ln','7778889999'),
('Pizza Hut','246 Deli St','8889990000'),
('Chick-fil-A','369 BBQ Rd','9990001111'),
('Dunkin Donuts','482 Ice Cream Ave','0001112222');

-- 3.3 Menu items
INSERT INTO MenuItem (RestaurantID,Name,Description,Price) VALUES
(1,'Big Mac','Classic Big Mac burger',5.99),
(1,'French Fries','Crispy golden fries',2.99),
(2,'Whopper','Flame-grilled beef burger',6.99),
(2,'Chicken Fries','Crispy chicken fries',4.99),
(3,'Crunchwrap Supreme','Grilled tortilla with beef and cheese',4.49),
(3,'Taco','Classic crunchy taco',1.99),
(4,'Italian BMT','Spicy Italian sub',6.49),
(4,'Turkey Breast','Lean turkey breast sub',5.99),
(5,'Pepperoni Pizza','Classic pepperoni pizza',9.99),
(5,'Cheese Pizza','Classic cheese pizza',8.99);

-- 3.4 Orders
INSERT INTO Orders (CustomerID,OrderDate,Status,TotalPrice) VALUES
(1,'2023-10-01','Completed',20.98),
(2,'2023-10-02','Out for Delivery',19.98),
(3,'2023-10-03','Preparing',8.98),
(4,'2023-10-04','Completed',27.98),
(5,'2023-10-05','Canceled',24.98),
(6,'2023-10-06','Completed',35.97),
(7,'2023-10-07','Out for Delivery',18.99),
(8,'2023-10-08','Preparing',22.99),
(9,'2023-10-09','Completed',30.99),
(10,'2023-10-10','Pending',15.99);

-- 3.5 Payments
INSERT INTO Payment (OrderID,PaymentMethod,Amount,Status) VALUES
(1,'Card',20.98,'Success'),
(2,'PayPal',19.98,'Success'),
(3,'Apple Pay',8.98,'Failed'),
(4,'Card',27.98,'Success'),
(5,'PayPal',24.98,'Failed'),
(6,'Card',35.97,'Success'),
(7,'Apple Pay',18.99,'Success'),
(8,'Card',22.99,'Failed'),
(9,'PayPal',30.99,'Success'),
(10,'Card',15.99,'Failed');

-- 3.6 Drivers
INSERT INTO DeliveryDriver (Name,Phone,VehicleType) VALUES
('Mike Johnson','1112223333','Motorcycle'),
('Sarah Lee','2223334444','Car'),
('Chris Brown','3334445555','Bicycle'),
('Emily Davis','4445556666','Car'),
('David Wilson','5556667777','Motorcycle'),
('Laura Green','6667778888','Car'),
('Kevin White','7778889999','Bicycle'),
('Olivia Black','8889990000','Car'),
('Daniel Taylor','9990001111','Motorcycle'),
('Sophia Martinez','0001112222','Car');

-- 3.7 Deliveries
INSERT INTO Delivery (OrderID,DriverID,PickupTime,DeliveryTime,Status) VALUES
(1,1,'2023-10-01 12:00','2023-10-01 12:30','Delivered'),
(2,2,'2023-10-02 13:00','2023-10-02 13:45','In Transit'),
(3,3,'2023-10-03 14:00',NULL,'In Transit'),
(4,4,'2023-10-04 15:00','2023-10-04 15:30','Delivered'),
(5,5,'2023-10-05 16:00',NULL,'Failed'),
(6,6,'2023-10-06 17:00','2023-10-06 17:45','Delivered'),
(7,7,'2023-10-07 18:00','2023-10-07 18:30','Delivered'),
(8,8,'2023-10-08 19:00',NULL,'In Transit'),
(9,9,'2023-10-09 20:00','2023-10-09 20:30','Delivered'),
(10,10,'2023-10-10 21:00',NULL,'In Transit');

-- 3.8 Reviews
INSERT INTO Review (CustomerID,RestaurantID,DriverID,Rating,ReviewComment,ReviewDate,ReviewType) VALUES
(1,1,1,5,'Great food and fast delivery!','2023-10-01','R'),
(2,2,2,4,'Good burgers, but delivery was late.','2023-10-02','R'),
(3,3,3,3,'Tacos were okay, but the driver was rude.','2023-10-03','D'),
(4,4,4,5,'Amazing subs and friendly driver!','2023-10-04','R'),
(5,5,5,2,'Pizza was cold and delivery took forever.','2023-10-05','R'),
(6,6,6,5,'Best fried chicken ever!','2023-10-06','R'),
(7,7,7,4,'Great coffee, but the driver got lost.','2023-10-07','D'),
(8,8,8,3,'Pizza was average, but the driver was nice.','2023-10-08','D'),
(9,9,9,5,'Fantastic chicken sandwich!','2023-10-09','R'),
(10,10,10,4,'Good donuts, but the driver was late.','2023-10-10','D');

-- 3.9 Promotions
INSERT INTO Promotion (RestaurantID,DiscountPercentage,StartDate,EndDate) VALUES
(1,10,'2023-10-01','2023-10-31'),
(2,15,'2023-10-01','2023-10-31'),
(3,20,'2023-10-01','2023-10-31'),
(4,10,'2023-10-01','2023-10-31'),
(5,25,'2023-10-01','2023-10-31'),
(6,10,'2023-10-01','2023-10-31'),
(7,15,'2023-10-01','2023-10-31'),
(8,10,'2023-10-01','2023-10-31'),
(9,20,'2023-10-01','2023-10-31'),
(10,10,'2023-10-01','2023-10-31');

-- 3.10 Applied Promotions
INSERT INTO AppliedPromotion (CustomerID,PromoID) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5);

-- 4. CREATE STORED PROCEDURES & FUNCTIONS

-- 4.1 Update delivery status and set DeliveryTime when completed
CREATE OR REPLACE PROCEDURE UpdateDeliveryStatus(
    p_delivery_id INT,
    p_new_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_new_status NOT IN ('In Transit','Delivered','Failed') THEN
        RAISE EXCEPTION 'Invalid status: %', p_new_status;
    END IF;
    UPDATE Delivery
    SET Status = p_new_status,
        DeliveryTime = CASE WHEN p_new_status = 'Delivered' THEN CURRENT_TIMESTAMP ELSE DeliveryTime END
    WHERE DeliveryID = p_delivery_id;
END;$$;

-- 4.2 Print summary of all orders for a customer via notices
CREATE OR REPLACE PROCEDURE GetCustomerOrderSummary(
    p_customer_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE 'OrderID | TotalPrice | PaymentStatus | DeliveryStatus';
    FOR r IN
        SELECT o.OrderID, o.TotalPrice, p.Status AS PaymentStatus, d.Status AS DeliveryStatus
        FROM Orders o
        JOIN Payment p ON o.OrderID = p.OrderID
        JOIN Delivery d ON o.OrderID = d.OrderID
        WHERE o.CustomerID = p_customer_id
    LOOP
        RAISE NOTICE '% | % | % | %', r.OrderID, r.TotalPrice, r.PaymentStatus, r.DeliveryStatus;
    END LOOP;
END;$$;

-- 4.3 Apply an active promotion to a customer
CREATE OR REPLACE PROCEDURE ApplyPromotionToCustomer(
    p_customer_id INT,
    p_promo_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    is_valid BOOLEAN;
BEGIN
    SELECT CURRENT_DATE BETWEEN StartDate AND EndDate INTO is_valid
    FROM Promotion WHERE PromoID = p_promo_id;
    IF NOT FOUND OR NOT is_valid THEN
        RAISE EXCEPTION 'Promo % is not active.', p_promo_id;
    END IF;
    INSERT INTO AppliedPromotion (CustomerID,PromoID) VALUES (p_customer_id,p_promo_id)
    ON CONFLICT DO NOTHING;
END;$$;

-- 4.4 Function to calculate average rating for a restaurant
CREATE OR REPLACE FUNCTION CalculateAvgRatingForRestaurant(
    p_restaurant_id INT
) RETURNS DECIMAL(5,2) LANGUAGE plpgsql AS $$
DECLARE
    avg_rating DECIMAL(5,2);
BEGIN
    SELECT ROUND(AVG(Rating),2) INTO avg_rating
    FROM Review WHERE RestaurantID = p_restaurant_id;
    RETURN COALESCE(avg_rating,0.00);
END;$$;

-- 5. CREATE TRIGGERS & AUDIT LOGS

-- 5.1 Log deleted orders
CREATE TABLE IF NOT EXISTS DeletedOrdersLog (
    LogID SERIAL PRIMARY KEY,
    OrderID INT,
    DeletedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CustomerID INT,
    TotalPrice NUMERIC(10,2)
);
CREATE OR REPLACE FUNCTION log_deleted_order() RETURNS TRIGGER LANGUAGE plpgsql AS $$BEGIN
    INSERT INTO DeletedOrdersLog(OrderID,CustomerID,TotalPrice)
    VALUES(OLD.OrderID,OLD.CustomerID,OLD.TotalPrice);
    RETURN OLD;
END;$$;
CREATE TRIGGER trg_log_order_delete AFTER DELETE ON Orders FOR EACH ROW EXECUTE FUNCTION log_deleted_order();

-- 5.2 Update order status on payment success
CREATE OR REPLACE FUNCTION update_order_on_payment() RETURNS TRIGGER LANGUAGE plpgsql AS $$BEGIN
    IF NEW.Status = 'Success' THEN
        UPDATE Orders SET Status='Completed' WHERE OrderID=NEW.OrderID;
    END IF;
    RETURN NEW;
END;$$;
CREATE TRIGGER trg_update_order_on_payment AFTER INSERT ON Payment FOR EACH ROW EXECUTE FUNCTION update_order_on_payment();

-- 5.3 Audit customer contact changes
CREATE TABLE IF NOT EXISTS CustomerAudit (
    AuditID SERIAL PRIMARY KEY,
    CustomerID INT,
    OldPhone VARCHAR(15),
    OldEmail VARCHAR(100),
    ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE FUNCTION log_customer_update() RETURNS TRIGGER LANGUAGE plpgsql AS $$BEGIN
    INSERT INTO CustomerAudit(CustomerID,OldPhone,OldEmail)
    VALUES(OLD.CustomerID,OLD.Phone,OLD.Email);
    RETURN NEW;
END;$$;
CREATE TRIGGER trg_customer_update_log BEFORE UPDATE ON Customer
FOR EACH ROW WHEN (OLD.Phone IS DISTINCT FROM NEW.Phone OR OLD.Email IS DISTINCT FROM NEW.Email)
EXECUTE FUNCTION log_customer_update();

-- 5.4 Zero out refunded payments
CREATE OR REPLACE FUNCTION zero_refund_amount() RETURNS TRIGGER LANGUAGE plpgsql AS $$BEGIN
    IF NEW.Status='Refunded' THEN NEW.Amount:=0; END IF;
    RETURN NEW;
END;$$;
CREATE TRIGGER trg_zero_payment_on_refund BEFORE UPDATE ON Payment FOR EACH ROW EXECUTE FUNCTION zero_refund_amount();

-- 6. CREATE VIEWS for reporting

-- 6.1 Completed orders with successful payments
CREATE VIEW CompletedOrdersWithSuccessfulPayments AS
SELECT o.OrderID, o.CustomerID, c.Name AS CustomerName, o.OrderDate, o.TotalPrice, p.PaymentMethod, p.Amount
FROM Orders o
JOIN Payment p ON o.OrderID=p.OrderID
JOIN Customer c ON o.CustomerID=c.CustomerID
WHERE o.Status='Completed' AND p.Status='Success';

-- 6.2 Driver delivery stats
CREATE VIEW DriverDeliveryStats AS
SELECT dd.DriverID, dd.Name AS DriverName,
    COUNT(*) AS TotalDeliveries,
    SUM(CASE WHEN d.Status='Delivered' THEN 1 ELSE 0 END) AS DeliveredCount,
    SUM(CASE WHEN d.Status='Failed' THEN 1 ELSE 0 END)    AS FailedCount,
    SUM(CASE WHEN d.Status='In Transit' THEN 1 ELSE 0 END) AS InTransitCount
FROM Delivery d
JOIN DeliveryDriver dd ON d.DriverID=dd.DriverID
GROUP BY dd.DriverID,dd.Name;

-- 6.3 Updatable customer view
CREATE VIEW BasicCustomerView AS
SELECT CustomerID,Name,Email,Phone FROM Customer;

-- 6.4 Restaurant average ratings
CREATE VIEW RestaurantAverageRatings AS
SELECT r.RestaurantID, r.Name AS RestaurantName,
    ROUND(AVG(rv.Rating),2) AS AverageRating,
    COUNT(rv.ReviewID) AS NumberOfReviews
FROM Restaurant r
JOIN Review rv ON r.RestaurantID=rv.RestaurantID AND rv.ReviewType='R'
GROUP BY r.RestaurantID, r.Name;
