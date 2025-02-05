-- 図書マスタ
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100) NOT NULL,
    publication_date DATE NOT NULL,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    total_copies INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 蔵書状態
CREATE TABLE book_copies (
    copy_id INT PRIMARY KEY,
    book_id INT NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'available', 'borrowed', 'maintenance', 'lost'
    acquisition_date DATE NOT NULL,
    last_maintenance_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- 貸出履歴
CREATE TABLE borrowing_history (
    borrowing_id INT PRIMARY KEY,
    copy_id INT NOT NULL,
    user_id INT NOT NULL,
    borrowed_date DATE NOT NULL,
    due_date DATE NOT NULL,
    returned_date DATE,
    extension_count INT DEFAULT 0,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id)
);

-- 予約履歴
CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    reservation_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'waiting', 'fulfilled', 'cancelled'
    fulfilled_date TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
