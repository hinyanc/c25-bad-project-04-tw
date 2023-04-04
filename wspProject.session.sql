-- inserting data into 'orders'
INSERT INTO orders (
    pick_up_date,
    pick_up_time,
    pick_up_district,
    pick_up_address,
    pick_up_coordinates,
    deliver_district,
    deliver_address,
    deliver_coordinates,
    users_id,
    drivers_id,
    distance_km,
    distance_price,
    reference_code,
    orders_status,
    token,
    remarks,
    created_at
  )
VALUES (
    '2023-03-29',
    '12:00',
    'Tsuen_Wan',
    'Nil',
    '(1, 1)',
    'Kowloon_Tong',
    'Nil',
    '(2, 2)',
    1,
    1,
    100,
    1000,
    gen_random_uuid(),
    '1 pending',
    'ehrugh83409tgj4wigo',
    'Nil',
    NOW()
  );

--


INSERT INTO order_animals (
    orders_id,
    animals_id,
    animals_amount,
    animals_unit_price
  )
VALUES (
    1,
    1,
    2,
    1000
  );


INSERT INTO orders (
    pick_up_date,
    pick_up_time,
    pick_up_district,
    pick_up_address,
    pick_up_coordinates,
    deliver_district,
    deliver_address,
    deliver_coordinates,
    users_id,
    drivers_id,
    distance_km,
    distance_price,
    orders_status,
    remarks,
    created_at
  )
VALUES (
    '2023-03-30',
    '13:00',
    'Tsuen_Wan',
    '20B, TML Tower',
    '(1, 2)',
    'Tuen_Mun',
    '15A, Tower 1, Sun Tuen Mun Center',
    '(2, 3)',
    1,
    1,
    25,
    10,
    '1 pending',
    'DLLM',
    NOW()
  );




-- query

SELECT pick_up_district, deliver_district, pick_up_date, pick_up_time, animals.animals_name, order_animals.animals_amount
FROM orders 
JOIN order_animals ON order_animals.orders_id = orders.id
JOIN animals ON animals.id = order_animals.animals_id
;

select * from order_animals;

select * from orders
JOIN users ON orders.users_id = users.id
JOIN order_animals ON order_animals.orders_id = orders.id 
WHERE orders_status = 'driver accepts' ;

SELECT orders.id, reference_code, 
CONCAT(users.title, ' ', users.first_name, ' ', users.last_name) AS user_full_name, 
users.contact_num, 
CONCAT(pick_up_date, ' ', pick_up_time) AS pick_up_date_time, 
CONCAT(pick_up_room, ' ', pick_up_floor, ' ', pick_up_building, ' ', pick_up_street, ' ', pick_up_district) AS pick_up_address, 
CONCAT(deliver_room, ' ', deliver_floor, ' ', deliver_building, ' ', deliver_street, ' ', deliver_district) AS deliver_address, 
json_agg(animals.animals_name) AS animals_name, 
json_agg(order_animals.animals_amount) AS animals_amount, 
remarks
FROM orders 
JOIN users ON orders.users_id = users.id
JOIN order_animals ON order_animals.orders_id = orders.id 
JOIN animals ON animals.id = order_animals.animals_id
-- WHERE orders_status = 'driver accepts' 
GROUP BY orders.id, reference_code, user_full_name, contact_num, pick_up_date_time, pick_up_address, deliver_address, remarks

SELECT 
    CONCAT(pick_up_date,' ',pick_up_time) AS pick_up_date_time,
      CONCAT(pick_up_room,' ',pick_up_floor,' ',pick_up_building,' ',pick_up_street,' ',pick_up_district) AS pick_up_address,
      CONCAT(deliver_room,' ',deliver_floor,' ',deliver_building,' ',deliver_street,' ',deliver_district) AS deliver_address,
      json_agg(animals.animals_name) AS animals_name,
      json_agg(order_animals.animals_amount) AS animals_amount,
      remarks,
      distance_km,
      SUM(distance_km * distance_price) AS distance_total_price,
      SUM(order_animals.animals_history_price * order_animals.animals_amount) AS animals_total_price,
      SUM((distance_km * distance_price)+(order_animals.animals_history_price * order_animals.animals_amount)) AS total_price
      FROM orders
      JOIN order_animals ON order_animals.orders_id = orders.id
      JOIN animals ON animals.id = order_animals.animals_id
      WHERE orders.orders_status ='not pay yet' AND orders.users_id = 2
    GROUP BY remarks, distance_km,pick_up_date_time,pick_up_address,deliver_address





    SELECT 
  orders.id,
  TO_CHAR(orders.created_at, 'YYYY-MM-DD HH24:MI:SS') AS created_at,
  CONCAT(pick_up_room,' ',pick_up_floor,' ',pick_up_building,' ',pick_up_street,' ',pick_up_district) AS pick_up_address,
  CONCAT(deliver_room,' ',deliver_floor,' ',deliver_building,' ',deliver_street,' ',deliver_district) AS deliver_address,
  CONCAT(pick_up_date,' ',pick_up_time) AS pick_up_date_time,
  json_agg(animals.animals_name) AS animals_name,
  json_agg(order_animals.animals_amount) AS animals_amount,
  remarks,
  orders_status
  FROM orders
  JOIN
  order_animals ON order_animals.orders_id = orders.id
  JOIN
  animals ON animals.id = order_animals.animals_id
  WHERE
  orders_status NOT LIKE 'complete%'
  AND
  orders_status NOT LIKE 'not pay yet%'
  AND 
  orders.users_id = 2
  GROUP BY
  orders.id,created_at,remarks,orders_status
  ORDER BY
  created_at DESC


-- ongoing order detail
SELECT 
CONCAT(drivers.title,' ',drivers.first_name,' ',drivers.last_name) AS full_name,
drivers.contact_num,
drivers.car_license_num 
FROM drivers
JOIN
orders ON orders.drivers_id = drivers.id
WHERE
orders.id = 7

-- history order
SELECT
orders.id,
reference_code,
orders_status,
json_agg(animals.animals_name) AS animals_name,
json_agg(order_animals.animals_amount) AS animals_amount
FROM orders
JOIN
order_animals ON order_animals.orders_id = orders.id
JOIN
animals ON animals.id = order_animals.animals_id
WHERE
orders_status = 'receiver received'
AND
orders.users_id = 1
GROUP BY 
orders.id,orders_status,reference_code


-- history order details
SELECT 
orders.id,
reference_code,
TO_CHAR(orders.created_at, 'YYYY-MM-DD HH24:MI:SS') AS created_at,orders_status,
CONCAT(pick_up_room,' ',pick_up_floor,' ',pick_up_building,' ',pick_up_street,' ',pick_up_district) AS pick_up_address,
CONCAT(deliver_room,' ',deliver_floor,' ',deliver_building,' ',deliver_street,' ',deliver_district) AS deliver_address,
CONCAT(pick_up_date,' ',pick_up_time) AS pick_up_date_time,
json_agg(animals.animals_name) AS animals_name,
json_agg(order_animals.animals_amount) AS animals_amount,
remarks

FROM orders
JOIN
order_animals ON order_animals.orders_id = orders.id
JOIN
animals ON animals.id = order_animals.animals_id
WHERE
orders_status = 'receiver received'
AND
orders.users_id = 1
AND
orders.id = 4
GROUP BY 
orders.id,reference_code,orders_status,remarks

