-- データベース作成
CREATE DATABASE IF NOT EXISTS ecommerce_reviews;
USE ecommerce_reviews;

-- テーブル作成
CREATE TABLE IF NOT EXISTS products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  price DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS reviews (
  review_id INT PRIMARY KEY,
  product_id INT,
  user_id INT,
  review_date DATE,
  review_data JSON,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 製品データの挿入
INSERT INTO products (product_id, name, category, price) VALUES
(1, 'Ultra HD Smart TV 50"', 'Electronics', 499.99),
(2, 'Wireless Noise-Cancelling Headphones', 'Electronics', 249.99),
(3, 'Professional Chef Knife Set', 'Kitchen', 129.99),
(4, 'Ergonomic Office Chair', 'Furniture', 189.99),
(5, 'Smart Fitness Tracker', 'Wearables', 79.99),
(6, 'Portable Bluetooth Speaker', 'Electronics', 59.99),
(7, 'Organic Cotton Bed Sheets', 'Home', 69.99),
(8, 'Stainless Steel Water Bottle', 'Kitchen', 24.99),
(9, 'Wireless Gaming Mouse', 'Electronics', 45.99),
(10, 'Indoor Plant Collection', 'Home', 34.99);

-- レビューデータの挿入
INSERT INTO reviews (review_id, product_id, user_id, review_date, review_data) VALUES
(1, 1, 101, '2025-01-15', '{
  "overall_rating": 4.5,
  "verified_purchase": true,
  "purchase_date": "2024-12-10",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 4}
  ],
  "usage_context": ["home", "entertainment"],
  "metadata": {
    "platform": "desktop",
    "country": "USA",
    "language": "en"
  }
}'),
(2, 1, 102, '2025-01-18', '{
  "overall_rating": 3.5,
  "verified_purchase": true,
  "purchase_date": "2024-12-28",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 3},
    {"aspect": "usability", "score": 3}
  ],
  "usage_context": ["home"],
  "metadata": {
    "platform": "mobile",
    "country": "Canada",
    "language": "en"
  }
}'),
(3, 2, 103, '2025-01-10', '{
  "overall_rating": 5.0,
  "verified_purchase": true,
  "purchase_date": "2024-12-05",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 5},
    {"aspect": "usability", "score": 5},
    {"aspect": "comfort", "score": 5}
  ],
  "usage_context": ["travel", "work", "commute"],
  "metadata": {
    "platform": "mobile",
    "country": "UK",
    "language": "en"
  }
}'),
(4, 2, 104, '2025-01-20', '{
  "overall_rating": 4.0,
  "verified_purchase": false,
  "purchase_date": null,
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 3},
    {"aspect": "usability", "score": 5},
    {"aspect": "comfort", "score": 4}
  ],
  "usage_context": ["travel"],
  "metadata": {
    "platform": "desktop",
    "country": "Germany",
    "language": "de"
  }
}'),
(5, 3, 105, '2025-01-05', '{
  "overall_rating": 4.8,
  "verified_purchase": true,
  "purchase_date": "2024-12-20",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 5},
    {"aspect": "sharpness", "score": 5}
  ],
  "usage_context": ["home", "professional"],
  "metadata": {
    "platform": "desktop",
    "country": "Japan",
    "language": "ja"
  }
}'),
(6, 3, 106, '2025-01-12', '{
  "overall_rating": 4.5,
  "verified_purchase": true,
  "purchase_date": "2024-12-25",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 4},
    {"aspect": "sharpness", "score": 5}
  ],
  "usage_context": ["home"],
  "metadata": {
    "platform": "mobile",
    "country": "France",
    "language": "fr"
  }
}'),
(7, 4, 107, '2025-01-22', '{
  "overall_rating": 4.0,
  "verified_purchase": true,
  "purchase_date": "2024-12-15",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 3},
    {"aspect": "comfort", "score": 5},
    {"aspect": "assembly", "score": 3}
  ],
  "usage_context": ["office", "work", "home"],
  "metadata": {
    "platform": "desktop",
    "country": "Australia",
    "language": "en"
  }
}'),
(8, 5, 108, '2025-01-25', '{
  "overall_rating": 3.5,
  "verified_purchase": true,
  "purchase_date": "2025-01-02",
  "detailed_ratings": [
    {"aspect": "quality", "score": 3},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 3},
    {"aspect": "accuracy", "score": 4}
  ],
  "usage_context": ["fitness", "outdoor"],
  "metadata": {
    "platform": "mobile",
    "country": "USA",
    "language": "en"
  }
}'),
(9, 6, 109, '2025-01-17', '{
  "overall_rating": 4.7,
  "verified_purchase": true,
  "purchase_date": "2024-12-30",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 5},
    {"aspect": "usability", "score": 4},
    {"aspect": "sound", "score": 5}
  ],
  "usage_context": ["outdoor", "travel", "home"],
  "metadata": {
    "platform": "mobile",
    "country": "Spain",
    "language": "es"
  }
}'),
(10, 7, 110, '2025-01-08', '{
  "overall_rating": 5.0,
  "verified_purchase": true,
  "purchase_date": "2024-12-10",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 5},
    {"aspect": "comfort", "score": 5},
    {"aspect": "durability", "score": 5}
  ],
  "usage_context": ["home", "bedroom"],
  "metadata": {
    "platform": "desktop",
    "country": "Canada",
    "language": "en"
  }
}'),
(11, 8, 111, '2025-01-14', '{
  "overall_rating": 4.2,
  "verified_purchase": false,
  "purchase_date": null,
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 3},
    {"aspect": "usability", "score": 4},
    {"aspect": "leak-proof", "score": 5}
  ],
  "usage_context": ["outdoor", "fitness", "travel"],
  "metadata": {
    "platform": "mobile",
    "country": "Italy",
    "language": "it"
  }
}'),
(12, 9, 112, '2025-01-19', '{
  "overall_rating": 4.8,
  "verified_purchase": true,
  "purchase_date": "2024-12-22",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 5},
    {"aspect": "responsiveness", "score": 5}
  ],
  "usage_context": ["gaming", "work"],
  "metadata": {
    "platform": "desktop",
    "country": "Brazil",
    "language": "pt"
  }
}'),
(13, 10, 113, '2025-01-16', '{
  "overall_rating": 3.8,
  "verified_purchase": true,
  "purchase_date": "2024-12-18",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 3},
    {"aspect": "health", "score": 4},
    {"aspect": "appearance", "score": 5}
  ],
  "usage_context": ["home", "office"],
  "metadata": {
    "platform": "mobile",
    "country": "Japan",
    "language": "ja"
  }
}'),
(14, 1, 114, '2025-01-28', '{
  "overall_rating": 4.0,
  "verified_purchase": true,
  "purchase_date": "2025-01-05",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 4}
  ],
  "usage_context": ["home", "entertainment"],
  "metadata": {
    "platform": "mobile",
    "country": "UK",
    "language": "en"
  }
}'),
(15, 2, 115, '2025-01-26', '{
  "overall_rating": 4.2,
  "verified_purchase": true,
  "purchase_date": "2025-01-02",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 4},
    {"aspect": "comfort", "score": 5}
  ],
  "usage_context": ["work", "commute"],
  "metadata": {
    "platform": "desktop",
    "country": "USA",
    "language": "en"
  }
}'),
(16, 5, 116, '2025-01-30', '{
  "overall_rating": 2.5,
  "verified_purchase": true,
  "purchase_date": "2025-01-10",
  "detailed_ratings": [
    {"aspect": "quality", "score": 2},
    {"aspect": "value", "score": 2},
    {"aspect": "usability", "score": 3},
    {"aspect": "accuracy", "score": 3}
  ],
  "usage_context": ["fitness"],
  "metadata": {
    "platform": "mobile",
    "country": "Germany",
    "language": "de"
  }
}'),
(17, 6, 117, '2025-01-29', '{
  "overall_rating": 4.6,
  "verified_purchase": false,
  "purchase_date": null,
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 5},
    {"aspect": "sound", "score": 4}
  ],
  "usage_context": ["home", "party"],
  "metadata": {
    "platform": "desktop",
    "country": "France",
    "language": "fr"
  }
}'),
(18, 4, 118, '2025-01-27', '{
  "overall_rating": 3.5,
  "verified_purchase": true,
  "purchase_date": "2025-01-05",
  "detailed_ratings": [
    {"aspect": "quality", "score": 3},
    {"aspect": "value", "score": 3},
    {"aspect": "comfort", "score": 4},
    {"aspect": "assembly", "score": 3}
  ],
  "usage_context": ["office", "home"],
  "metadata": {
    "platform": "mobile",
    "country": "Canada",
    "language": "en"
  }
}'),
(19, 8, 119, '2025-01-31', '{
  "overall_rating": 4.0,
  "verified_purchase": true,
  "purchase_date": "2025-01-15",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 4},
    {"aspect": "leak-proof", "score": 4}
  ],
  "usage_context": ["fitness", "office"],
  "metadata": {
    "platform": "mobile",
    "country": "Spain",
    "language": "es"
  }
}'),
(20, 10, 120, '2025-01-24', '{
  "overall_rating": 4.2,
  "verified_purchase": true,
  "purchase_date": "2025-01-08",
  "detailed_ratings": [
    {"aspect": "quality", "score": 4},
    {"aspect": "value", "score": 4},
    {"aspect": "health", "score": 5},
    {"aspect": "appearance", "score": 4}
  ],
  "usage_context": ["home", "gift"],
  "metadata": {
    "platform": "desktop",
    "country": "Australia",
    "language": "en"
  }
}');
