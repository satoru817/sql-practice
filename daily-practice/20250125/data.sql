-- Insert sample data
INSERT INTO customers VALUES
(1, 'John Smith', '2023-01-15', 'USA'),
(2, 'Maria Garcia', '2023-02-20', 'Spain'),
(3, 'Yuki Tanaka', '2023-03-10', 'Japan'),
(4, 'Emma Brown', '2023-04-05', 'UK'),
(5, 'Lucas Silva', '2023-05-15', 'Brazil');

INSERT INTO products VALUES
(1, 'Laptop Pro', 'Electronics', 1200.00, 101),
(2, 'Wireless Mouse', 'Electronics', 25.00, 101),
(3, 'Office Chair', 'Furniture', 150.00, 102),
(4, 'Coffee Maker', 'Appliances', 80.00, 103),
(5, 'Desk Lamp', 'Furniture', 40.00, 102);

INSERT INTO orders VALUES
(1, 1, '2024-01-01'),
(2, 1, '2024-01-15'),
(3, 2, '2024-01-10'),
(4, 3, '2024-01-20'),
(5, 4, '2024-01-25'),
(6, 5, '2024-01-05'),
(7, 2, '2024-01-30'),
(8, 3, '2024-02-01');

INSERT INTO order_items VALUES
(1, 1, 1, 1200.00),
(1, 2, 2, 25.00),
(2, 3, 1, 150.00),
(3, 4, 1, 80.00),
(3, 5, 2, 40.00),
(4, 1, 1, 1200.00),
(5, 3, 2, 150.00),
(6, 2, 1, 25.00),
(7, 4, 2, 80.00),
(8, 5, 1, 40.00);

