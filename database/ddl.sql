SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;


-- Tracks store IDs, location, and franchisee.
CREATE OR REPLACE TABLE store (
  store_id INT AUTO_INCREMENT PRIMARY KEY,
  location VARCHAR(255) NOT NULL,
  franchisee VARCHAR(255) NOT NULL
);

-- Tracks products in store using information from orders:
CREATE OR REPLACE TABLE inventory (
  inventory_id INT NOT NULL PRIMARY KEY,
  store_id INT NOT NULL,
  milk_amount INT NOT NULL,               
  tea_amount INT NOT NULL,                      
  boba_amount INT NOT NULL, 
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE CASCADE  -- if the store is deleted inventory gets deleted  
);

-- Tracks employee information.
CREATE OR REPLACE TABLE employees (
  employee_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  birthdate DATE NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255) NOT NULL,
  store_id INT NOT NULL,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE CASCADE -- if the store is deleted all employees get deleted 
);

 -- tracks customer information used for returns and processing card charges | optinal relationship woth order
CREATE OR REPLACE TABLE customer (
  customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  name VARCHAR(255),
  FOREIGN KEY (order_id) REFERENCES `order`(order_id) ON DELETE CASCADE
);

-- Tracks menu items:
CREATE OR REPLACE TABLE menuItem (                        
  menu_item_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  inventory_id INT NOT NULL,
  item_cost DECIMAL(10,2) NOT NULL,  
  item_name varchar(255) NOT NULL, 
  FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
);

-- Tracks information on customer orders. Used to keep track of inventory levels 
CREATE OR REPLACE TABLE `order` (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NULL,                                                               -- default null to make optional 
  order_date DATE NOT NULL,
  order_time TIME NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  menu_item_id INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE SET NULL ,
  FOREIGN KEY (menu_item_id) REFERENCES menuItem(menu_item_id) ON DELETE CASCADE      -- when the item stopped being sold all records of the orders of it also deleted 
);


-- intersection table between menu items and orders M:N
CREATE OR REPLACE TABLE order_menu_item (
  order_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (order_id, menu_item_id),
  FOREIGN KEY (order_id) REFERENCES `order`(order_id) ON DELETE CASCADE,        -- either order or menuItem is deleted the respective intermediate table is deleted 
  FOREIGN KEY (menu_item_id) REFERENCES menuItem(menu_item_id) ON DELETE CASCADE
  
);



 -- insert data into the tables 
INSERT INTO store (location, franchisee)
VALUES 
  ('Portland', 'John Doe'),
  ('Los Angeles', 'Jane Doe'),
  ('San Jose', 'Jim Smith');

INSERT INTO inventory (inventory_id, store_id, milk_amount, tea_amount, boba_amount)
VALUES 
  (1, 1, 1000, 1000, 1000),
  (2, 2, 1500, 2000, 1400),
  (3, 3, 1000, 1500, 2000);

INSERT INTO employees (store_id, name, birthdate, address, phone_number)
VALUES 
  (1, 'Amy', '1995-06-28', '123 Main St', '000-000-0001'),
  (1, 'Tom', '1988-04-12', '456 Elm St', '000-000-0002'),
  (1, 'Sara', '1991-12-05', '789 Oak St', '000-000-0003');

INSERT INTO customer ( order_id, name)
VALUES 
  ( 1, 'Chris'),
  ( 2, 'Ava'),
  ( 3, 'Olivia');

INSERT INTO `order` (customer_id, order_date, order_time, total_amount, menu_item_id)
VALUES 
  (1, '2022-01-01', '10:00:00', 15.99, 1),
  (2, '2022-01-02', '11:00:00', 12.99, 2),
  (3, '2022-01-03', '12:00:00', 19.99, 3);

INSERT INTO menuItem (item_name, inventory_id, item_cost)
VALUES 
  ('milk_tea', 1, 5.00),
  ('green_tea', 2, 5.50),
  ('winter_melon', 3, 6.00);

INSERT INTO order_menu_item (order_id, menu_item_id, quantity)
VALUES 
  (1, 1, 2),
  (2, 2, 3),
  (3, 3, 4);



-- have to insert this manually in the GUI mySQL does not like (doesn't like its own export either)
-- CREATE TRIGGER calculate_order_menu_item_quantity
-- AFTER INSERT ON `order`
-- FOR EACH ROW
-- BEGIN
--   INSERT INTO order_menu_item (order_id, menu_item_id, quantity)
--   SELECT NEW.order_id, menuItem.menu_item_id, NEW.total_amount DIV menuItem.item_cost
--   FROM menuItem
--   WHERE menuItem.menu_item_id = NEW.menu_item_id;
-- END


-- CREATE TRIGGER decrement_inventory_trigger
-- AFTER INSERT ON order_menu_item
-- FOR EACH ROW
-- BEGIN
--     UPDATE inventory
--     JOIN menuItem ON inventory.inventory_id = menuItem.inventory_id
--     SET milk_amount = milk_amount - NEW.quantity,
--         tea_amount = tea_amount - NEW.quantity,
--         boba_amount = boba_amount - NEW.quantity
--     WHERE menuItem.menu_item_id = NEW.menu_item_id;
-- END;




SET FOREIGN_KEY_CHECKS=1;
COMMIT;
