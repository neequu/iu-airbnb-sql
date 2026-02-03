CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    profile_photo_url VARCHAR(255),
    bio TEXT
);
CREATE TABLE Amenity (
    amenity_id SERIAL PRIMARY KEY,
    amenity_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50),
    icon_url VARCHAR(255)
);
CREATE TABLE Property (
    property_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    
    property_type VARCHAR(20) NOT NULL CHECK (property_type IN ('entire_home', 'private_room', 'shared_room')),
    max_guests INTEGER NOT NULL CHECK (max_guests > 0),
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0),
    beds INTEGER NOT NULL CHECK (beds >= 0),
    bathrooms DECIMAL(3,1) NOT NULL CHECK (bathrooms >= 0),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (host_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Address (
    address_id SERIAL PRIMARY KEY,
    property_id INTEGER UNIQUE NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8) CHECK (latitude >= -90 AND latitude <= 90),
    longitude DECIMAL(11,8) CHECK (longitude >= -180 AND longitude <= 180),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);
CREATE TABLE Photo (
    photo_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    caption VARCHAR(200),
    display_order INTEGER NOT NULL,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);


CREATE TABLE House_Rule (
    rule_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    rule_text VARCHAR(500) NOT NULL,
    rule_category VARCHAR(50),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);


CREATE TABLE Cancellation_Policy (
    policy_id SERIAL PRIMARY KEY,
    property_id INTEGER UNIQUE NOT NULL,
    policy_type VARCHAR(20) NOT NULL CHECK (policy_type IN ('flexible', 'moderate', 'strict')),
    refund_percentage DECIMAL(5,2) NOT NULL CHECK (refund_percentage >= 0 AND refund_percentage <= 100),
    notice_days INTEGER NOT NULL CHECK (notice_days >= 0),
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);
CREATE TABLE Pricing (
    pricing_id SERIAL PRIMARY KEY,
    property_id INTEGER UNIQUE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0),
    cleaning_fee DECIMAL(10,2) CHECK (cleaning_fee >= 0),
    guest_fee_percentage DECIMAL(5,2) CHECK (guest_fee_percentage >= 6.00 AND guest_fee_percentage <= 12.00),
    host_fee_percentage DECIMAL(5,2) DEFAULT 3.00,
    currency VARCHAR(3) DEFAULT 'USD',
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);


CREATE TABLE Availability (
    availability_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    available_date DATE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    custom_price DECIMAL(10,2) CHECK (custom_price IS NULL OR custom_price > 0),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);
CREATE TABLE Income_Calculator (
    calculation_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    calculated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estimated_monthly_income DECIMAL(10,2) CHECK (estimated_monthly_income IS NULL OR estimated_monthly_income >= 0),
    occupancy_rate DECIMAL(5,2) CHECK (occupancy_rate IS NULL OR (occupancy_rate >= 0 AND occupancy_rate <= 100)),
    comparable_properties_avg DECIMAL(10,2) CHECK (comparable_properties_avg IS NULL OR comparable_properties_avg >= 0),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);

CREATE TABLE Host_Profile (
    host_profile_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL,
    response_rate DECIMAL(5,2) CHECK (response_rate >= 0 AND response_rate <= 100),
    response_time INTEGER,
    hosting_since DATE,
    is_superhost BOOLEAN DEFAULT FALSE,
    government_id_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Guest_Profile (
    guest_profile_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL,
    preferred_language VARCHAR(10),
    emergency_contact VARCHAR(100),
    identity_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


CREATE TABLE Payment_Method (
    payment_method_id SERIAL PRIMARY KEY,
    guest_id INTEGER NOT NULL,
    method_type VARCHAR(20) NOT NULL CHECK (method_type IN ('credit_card', 'debit_card', 'paypal')),
    card_last_four VARCHAR(4),
    expiry_date DATE,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (guest_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL CHECK (check_out_date > check_in_date),
    num_guests INTEGER NOT NULL CHECK (num_guests > 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
    booking_status VARCHAR(20) NOT NULL CHECK (booking_status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    special_requests TEXT,
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE RESTRICT,
    FOREIGN KEY (guest_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    payment_method_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(20) NOT NULL CHECK (payment_status IN ('pending', 'completed', 'refunded', 'failed')),
    transaction_reference VARCHAR(100),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT,
    FOREIGN KEY (payment_method_id) REFERENCES Payment_Method(payment_method_id) ON DELETE RESTRICT
);
CREATE TABLE Payout (
    payout_id SERIAL PRIMARY KEY,
    booking_id INTEGER UNIQUE NOT NULL,
    host_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payout_date TIMESTAMP,
    payout_status VARCHAR(20) NOT NULL CHECK (payout_status IN ('scheduled', 'completed', 'held')),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT,
    FOREIGN KEY (host_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);


CREATE TABLE Review (
    review_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    reviewee_id INTEGER NOT NULL,
    review_type VARCHAR(20) NOT NULL CHECK (review_type IN ('guest_to_host', 'host_to_guest')),
    rating_overall INTEGER NOT NULL CHECK (rating_overall >= 1 AND rating_overall <= 5),
    rating_cleanliness INTEGER CHECK (rating_cleanliness IS NULL OR (rating_cleanliness >= 1 AND rating_cleanliness <= 5)),
    rating_communication INTEGER NOT NULL CHECK (rating_communication >= 1 AND rating_communication <= 5),
    rating_accuracy INTEGER CHECK (rating_accuracy IS NULL OR (rating_accuracy >= 1 AND rating_accuracy <= 5)),
    rating_location INTEGER CHECK (rating_location IS NULL OR (rating_location >= 1 AND rating_location <= 5)),
    rating_value INTEGER CHECK (rating_value IS NULL OR (rating_value >= 1 AND rating_value <= 5)),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT,
    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (reviewee_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);


CREATE TABLE Review_Response (
    response_id SERIAL PRIMARY KEY,
    review_id INTEGER UNIQUE NOT NULL,
    responder_id INTEGER NOT NULL,
    response_text TEXT NOT NULL,
    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES Review(review_id) ON DELETE CASCADE,
    FOREIGN KEY (responder_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

CREATE TABLE Conversation (
    conversation_id SERIAL PRIMARY KEY,
    booking_id INTEGER,
    participant1_id INTEGER NOT NULL,
    participant2_id INTEGER NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_message_date TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE SET NULL,
    FOREIGN KEY (participant1_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (participant2_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

CREATE TABLE Message (
    message_id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    message_text TEXT NOT NULL,
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (conversation_id) REFERENCES Conversation(conversation_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

CREATE TABLE Social_Connection (
    connection_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    platform VARCHAR(50) NOT NULL,
    platform_user_id VARCHAR(100) NOT NULL,
    connection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


CREATE TABLE Verification_Document (
    document_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    document_type VARCHAR(30) NOT NULL CHECK (document_type IN ('government_id', 'passport', 'drivers_license')),
    document_url VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(20) NOT NULL CHECK (verification_status IN ('pending', 'approved', 'rejected')),
    verified_by_admin_id INTEGER,
    verified_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by_admin_id) REFERENCES Users(user_id) ON DELETE SET NULL
);
CREATE TABLE Property_Amenity (
    property_id INTEGER NOT NULL,
    amenity_id INTEGER NOT NULL,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenity(amenity_id) ON DELETE CASCADE
);

CREATE TABLE Booking_Guest_Payment (
    booking_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    payment_id INTEGER NOT NULL,
    PRIMARY KEY (booking_id, guest_id, payment_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT,
    FOREIGN KEY (guest_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id) ON DELETE RESTRICT
);

CREATE TABLE Booking_Host_Payout (
    booking_id INTEGER NOT NULL,
    host_id INTEGER NOT NULL,
    payout_id INTEGER NOT NULL,
    PRIMARY KEY (booking_id, host_id, payout_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT,
    FOREIGN KEY (host_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (payout_id) REFERENCES Payout(payout_id) ON DELETE RESTRICT
);

CREATE TABLE Dispute (
    dispute_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    complainant_id INTEGER NOT NULL,
    respondent_id INTEGER NOT NULL,
    admin_id INTEGER,
    dispute_reason TEXT NOT NULL,
    dispute_status VARCHAR(20) NOT NULL CHECK (dispute_status IN ('open', 'in_progress', 'resolved', 'closed')),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolution_date TIMESTAMP,
    resolution_notes TEXT,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT,
    FOREIGN KEY (complainant_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (respondent_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (admin_id) REFERENCES Users(user_id) ON DELETE SET NULL
);
INSERT INTO Users (email,
 password_hash,
 first_name,
 last_name,
 phone,
 date_of_birth,
 registration_date,
 last_login,
 is_verified,
 profile_photo_url,
 bio) VALUES
('sato.taro@example.jp', 
'$2a$10$pw', 
'Taro', 
'Sato', 
'080-1234-5678', 
'1985-03-15', 
'2023-01-15 10:30:00', 
'2024-01-20 14:22:00', 
TRUE, 
'https://x.com/profiles/sato.jpg', 
'Tokyo-based host'),
('suzuki.hanako@example.jp', '$2a$10$hashedpassword2', 'Hanako', 'Suzuki', '090-9876-5432', '1990-07-22', '2023-02-20 09:15:00', '2024-01-18 11:45:00', TRUE, 'https://example.com/profiles/suzuki.jpg', 'Guest house operator in Kyoto'),
('takahashi.yuki@example.jp', '$2a$10$hashedpassword3', 'Yuki', 'Takahashi', '080-3333-4444', '1988-11-05', '2023-03-10 14:20:00', '2024-01-22 16:30:00', TRUE, 'https://example.com/profiles/takahashi.jpg', 'From Hokkaido, loves hot springs'),
('tanaka.ryo@example.jp', '$2a$10$hashedpassword4', 'Ryo', 'Tanaka', '090-5555-6666', '1992-04-30', '2023-04-05 11:00:00', '2024-01-19 09:15:00', TRUE, 'https://example.com/profiles/tanaka.jpg', 'Architect from Osaka'),
('watanabe.akira@example.jp', '$2a$10$hashedpassword5', 'Akira', 'Watanabe', '080-7777-8888', '1983-09-12', '2023-05-18 16:45:00', '2024-01-21 13:20:00', FALSE, 'https://example.com/profiles/watanabe.jpg', 'Travel blogger'),
('ito.mai@example.jp', '$2a$10$hashedpassword6', 'Mai', 'Ito', '090-2222-1111', '1995-12-08', '2023-06-22 08:30:00', '2024-01-17 10:45:00', TRUE, 'https://example.com/profiles/ito.jpg', 'Student from Fukuoka'),
('yamamoto.kenji@example.jp', '$2a$10$hashedpassword7', 'Kenji', 'Yamamoto', '080-9999-0000', '1978-06-25', '2023-07-14 12:15:00', '2024-01-23 15:10:00', TRUE, 'https://example.com/profiles/yamamoto.jpg', 'Retired teacher, Nagoya'),
('nakamura.sakura@example.jp', '$2a$10$hashedpassword8', 'Sakura', 'Nakamura', '090-4444-3333', '1991-02-14', '2023-08-03 14:50:00', '2024-01-16 12:30:00', TRUE, 'https://example.com/profiles/nakamura.jpg', 'Chef from Yokohama'),
('kobayashi.hiroshi@example.jp', '$2a$10$hashedpassword9', 'Hiroshi', 'Kobayashi', '080-6666-7777', '1987-08-19', '2023-09-11 10:05:00', '2024-01-24 11:20:00', FALSE, 'https://example.com/profiles/kobayashi.jpg', 'Software engineer'),
('kato.megumi@example.jp', '$2a$10$hashedpassword10', 'Megumi', 'Kato', '090-8888-9999', '1993-10-03', '2023-10-09 09:40:00', '2024-01-25 14:15:00', TRUE, 'https://example.com/profiles/kato.jpg', 'Tour guide in Nara'),
('yoshida.takeshi@example.jp', '$2a$10$hashedpassword11', 'Takeshi', 'Yoshida', '080-1111-2222', '1980-01-28', '2023-11-17 15:25:00', '2024-01-15 16:40:00', TRUE, 'https://example.com/profiles/yoshida.jpg', 'Fishing enthusiast, Hokkaido'),
('yamada.naomi@example.jp', '$2a$10$hashedpassword12', 'Naomi', 'Yamada', '090-7777-5555', '1986-05-17', '2023-12-05 11:55:00', '2024-01-14 10:10:00', TRUE, 'https://example.com/profiles/yamada.jpg', 'Graphic designer from Kobe'),
('sasaki.kaito@example.jp', '$2a$10$hashedpassword13', 'Kaito', 'Sasaki', '080-2222-8888', '1994-03-08', '2024-01-02 08:20:00', '2024-01-26 09:05:00', FALSE, 'https://example.com/profiles/sasaki.jpg', 'University student'),
('matsumoto.yui@example.jp', '$2a$10$hashedpassword14', 'Yui', 'Matsumoto', '090-3333-9999', '1989-07-11', '2024-01-10 13:35:00', '2024-01-27 12:50:00', TRUE, 'https://example.com/profiles/matsumoto.jpg', 'Florist from Sapporo'),
('inoue.daiki@example.jp', '$2a$10$hashedpassword15', 'Daiki', 'Inoue', '080-4444-0000', '1984-12-22', '2024-01-18 16:10:00', '2024-01-28 15:25:00', TRUE, 'https://example.com/profiles/inoue.jpg', 'Business consultant'),
('kimura.emi@example.jp', '$2a$10$hashedpassword16', 'Emi', 'Kimura', '090-9999-1111', '1996-09-30', '2024-01-25 10:45:00', '2024-01-29 14:30:00', FALSE, 'https://example.com/profiles/kimura.jpg', 'Part-time worker, Tokyo'),
('hayashi.ryota@example.jp', '$2a$10$hashedpassword17', 'Ryota', 'Hayashi', '080-5555-2222', '1982-04-05', '2024-02-01 09:15:00', '2024-01-30 11:15:00', TRUE, 'https://example.com/profiles/hayashi.jpg', 'Photographer'),
('shimizu.miyuki@example.jp', '$2a$10$hashedpassword18', 'Miyuki', 'Shimizu', '090-0000-4444', '1997-11-18', '2024-02-08 14:40:00', '2024-01-31 13:45:00', TRUE, 'https://example.com/profiles/shimizu.jpg', 'Nurse from Hiroshima'),
('yamazaki.takumi@example.jp', '$2a$10$hashedpassword19', 'Takumi', 'Yamazaki', '080-8888-3333', '1979-06-07', '2024-02-15 11:25:00', '2024-02-01 10:20:00', TRUE, 'https://example.com/profiles/yamazaki.jpg', 'Restaurant owner'),
('mori.rika@example.jp', '$2a$10$hashedpassword20', 'Rika', 'Mori', '090-6666-8888', '1998-02-25', '2024-02-22 16:50:00', '2024-02-02 15:35:00', FALSE, 'https://example.com/profiles/mori.jpg', 'Model from Nagasaki');

INSERT INTO Amenity (amenity_name, category, icon_url) VALUES
('WiFi', 'basic', 'https://example.com/icons/wifi.png'),
('Air Conditioning', 'basic', 'https://example.com/icons/ac.png'),
('Heating', 'basic', 'https://example.com/icons/heating.png'),
('Kitchen', 'basic', 'https://example.com/icons/kitchen.png'),
('Washer', 'basic', 'https://example.com/icons/washer.png'),
('Dryer', 'basic', 'https://example.com/icons/dryer.png'),
('TV', 'entertainment', 'https://example.com/icons/tv.png'),
('Netflix', 'entertainment', 'https://example.com/icons/netflix.png'),
('Swimming Pool', 'luxury', 'https://example.com/icons/pool.png'),
('Hot Tub', 'luxury', 'https://example.com/icons/hottub.png'),
('Free Parking', 'parking', 'https://example.com/icons/parking.png'),
('Paid Parking', 'parking', 'https://example.com/icons/paid_parking.png'),
('Elevator', 'accessibility', 'https://example.com/icons/elevator.png'),
('Wheelchair Accessible', 'accessibility', 'https://example.com/icons/wheelchair.png'),
('Security Cameras', 'safety', 'https://example.com/icons/camera.png'),
('Smoke Alarm', 'safety', 'https://example.com/icons/smoke_alarm.png'),
('Carbon Monoxide Alarm', 'safety', 'https://example.com/icons/co_alarm.png'),
('Fire Extinguisher', 'safety', 'https://example.com/icons/fire_extinguisher.png'),
('First Aid Kit', 'safety', 'https://example.com/icons/first_aid.png'),
('Balcony', 'outdoor', 'https://example.com/icons/balcony.png');

INSERT INTO Property (host_id, title, property_type, max_guests, bedrooms, beds, bathrooms, created_date, is_active) VALUES
(1, 'Modern Apartment in Shibuya', 'entire_home', 4, 2, 3, 1.5, '2023-03-15 10:00:00', TRUE),
(2, 'Traditional Machiya in Kyoto', 'entire_home', 6, 3, 4, 2.0, '2023-04-20 14:30:00', TRUE),
(3, 'Ski Lodge in Niseko', 'entire_home', 8, 4, 6, 3.0, '2023-05-10 09:15:00', TRUE),
(4, 'Osaka City Center Studio', 'entire_home', 2, 1, 1, 1.0, '2023-06-05 11:45:00', TRUE),
(5, 'Private Room in Shinjuku', 'private_room', 2, 1, 1, 1.0, '2023-07-12 16:20:00', TRUE),
(6, 'Fukuoka Riverside House', 'entire_home', 5, 3, 3, 2.0, '2023-08-18 13:10:00', TRUE),
(7, 'Nagoya Business Apartment', 'entire_home', 3, 2, 2, 1.0, '2023-09-22 08:40:00', TRUE),
(8, 'Yokohama Bay View Condo', 'entire_home', 4, 2, 3, 2.0, '2023-10-30 15:25:00', TRUE),
(9, 'Sapporo Winter Cottage', 'entire_home', 4, 2, 2, 1.5, '2023-11-14 10:50:00', TRUE),
(10, 'Nara Temple Stay', 'private_room', 3, 1, 2, 1.0, '2023-12-03 12:35:00', TRUE),
(11, 'Hakodate Historic House', 'entire_home', 7, 4, 5, 2.5, '2024-01-08 09:00:00', TRUE),
(12, 'Kobe Hillside Villa', 'entire_home', 10, 5, 8, 4.0, '2024-01-25 14:15:00', TRUE),
(13, 'Kanazawa Samurai House', 'entire_home', 6, 3, 4, 2.0, '2024-02-10 11:30:00', TRUE),
(14, 'Sendai Modern Loft', 'entire_home', 3, 1, 2, 1.0, '2024-02-28 16:45:00', TRUE),
(15, 'Hiroshima Peace Park Apartment', 'entire_home', 4, 2, 3, 1.5, '2024-03-15 13:20:00', TRUE),
(16, 'Tokyo Capsule Hotel', 'shared_room', 1, 1, 1, 1.0, '2024-03-30 10:05:00', TRUE),
(17, 'Kamakura Beach House', 'entire_home', 5, 3, 4, 2.0, '2024-04-12 08:50:00', FALSE),
(18, 'Matsumoto Castle View', 'entire_home', 3, 2, 2, 1.0, '2024-04-25 15:35:00', TRUE),
(19, 'Takayama Traditional Inn', 'entire_home', 8, 4, 6, 3.0, '2024-05-10 12:10:00', TRUE),
(20, 'Nagasaki Harbor Suite', 'entire_home', 2, 1, 1, 1.0, '2024-05-22 09:55:00', TRUE);

INSERT INTO Address (property_id, street_address, city, state_province, country, postal_code, latitude, longitude) 
VALUES
(1, '1-2-3 Shibuya', 'Shibuya', 'Tokyo', 'Japan', '150-0002', 35.658034, 139.701636),
(2, '456 Shimogyo-ku', 'Kyoto', 'Kyoto', 'Japan', '600-8216', 35.011564, 135.768149),
(3, '789 Niseko', 'Abuta', 'Hokkaido', 'Japan', '048-1511', 42.804817, 140.687676),
(4, '101 Dotonbori', 'Chuo', 'Osaka', 'Japan', '542-0071', 34.669675, 135.501987),
(5, '202 Shinjuku', 'Shinjuku', 'Tokyo', 'Japan', '160-0022', 35.693840, 139.703549),
(6, '303 Nakasu', 'Hakata', 'Fukuoka', 'Japan', '810-0801', 33.590355, 130.420685),
(7, '404 Nakamura-ku', 'Nagoya', 'Aichi', 'Japan', '453-0801', 35.168191, 136.910034),
(8, '505 Naka-ku', 'Yokohama', 'Kanagawa', 'Japan', '231-0023', 35.443708, 139.638025),
(9, '606 Chuo-ku', 'Sapporo', 'Hokkaido', 'Japan', '064-0806', 43.061771, 141.354451),
(10, '707 Nara-shi', 'Nara', 'Nara', 'Japan', '630-8211', 34.685087, 135.805000),
(11, '808 Motomachi', 'Hakodate', 'Hokkaido', 'Japan', '040-0054', 41.768793, 140.728810),
(12, '909 Kitano-cho', 'Kobe', 'Hyogo', 'Japan', '650-0002', 34.702485, 135.189911),
(13, '1010 Nagamachi', 'Kanazawa', 'Ishikawa', 'Japan', '920-0865', 36.565725, 136.662292),
(14, '1111 Aoba-ku', 'Sendai', 'Miyagi', 'Japan', '980-0811', 38.268215, 140.869356),
(15, '1212 Naka-ku', 'Hiroshima', 'Hiroshima', 'Japan', '730-0811', 34.392559, 132.460831),
(16, '1313 Ginza', 'Chuo', 'Tokyo', 'Japan', '104-0061', 35.669987, 139.769597),
(17, '1414 Yuigahama', 'Kamakura', 'Kanagawa', 'Japan', '248-0014', 35.311054, 139.546648),
(18, '1515 Marunouchi', 'Matsumoto', 'Nagano', 'Japan', '390-0873', 36.238038, 137.972034),
(19, '1616 Kamiokamotomachi', 'Takayama', 'Gifu', 'Japan', '506-0055', 36.146112, 137.252157),
(20, '1717 Dejima-machi', 'Nagasaki', 'Nagasaki', 'Japan', '850-0862', 32.744839, 129.873444);

INSERT INTO Host_Profile (user_id, response_rate, response_time, hosting_since, is_superhost, government_id_verified) VALUES
(1, 98.50, 12, '2019-06-15', TRUE, TRUE),
(2, 95.20, 24, '2018-11-30', TRUE, TRUE),
(3, 99.10, 8, '2020-02-20', TRUE, TRUE),
(4, 92.80, 36, '2021-03-10', FALSE, TRUE),
(5, 87.50, 48, '2022-07-05', FALSE, FALSE),
(6, 96.30, 18, '2019-09-22', TRUE, TRUE),
(7, 100.00, 6, '2017-12-15', TRUE, TRUE),
(8, 94.70, 30, '2020-05-18', FALSE, TRUE),
(9, 89.20, 42, '2022-01-25', FALSE, TRUE),
(10, 97.80, 15, '2018-08-12', TRUE, TRUE),
(11, 93.40, 28, '2021-06-30', FALSE, TRUE),
(12, 99.50, 10, '2019-04-05', TRUE, TRUE),
(13, 91.60, 32, '2022-03-15', FALSE, FALSE),
(14, 98.90, 14, '2020-11-08', TRUE, TRUE),
(15, 95.70, 22, '2021-09-20', FALSE, TRUE),
(16, 88.30, 45, '2023-02-14', FALSE, TRUE),
(17, 96.80, 16, '2020-07-03', TRUE, TRUE),
(18, 94.10, 26, '2021-12-10', FALSE, TRUE),
(19, 100.00, 5, '2018-05-25', TRUE, TRUE),
(20, 92.50, 34, '2022-08-28', FALSE, TRUE);

INSERT INTO Guest_Profile (user_id, preferred_language, emergency_contact, identity_verified) VALUES
(1, 'ja', '080-9999-8888', TRUE),
(2, 'en', '090-7777-6666', TRUE),
(3, 'ja', '080-5555-4444', TRUE),
(4, 'en', '090-3333-2222', TRUE),
(5, 'ja', '080-1111-0000', FALSE),
(6, 'ko', '090-8888-7777', TRUE),
(7, 'ja', '080-6666-5555', TRUE),
(8, 'zh', '090-4444-3333', TRUE),
(9, 'ja', '080-2222-1111', TRUE),
(10, 'en', '090-0000-9999', TRUE),
(11, 'ja', '080-7777-8888', TRUE),
(12, 'fr', '090-5555-6666', TRUE),
(13, 'ja', '080-3333-4444', FALSE),
(14, 'en', '090-1111-2222', TRUE),
(15, 'ja', '080-8888-9999', TRUE),
(16, 'ja', '090-6666-7777', FALSE),
(17, 'en', '080-4444-5555', TRUE),
(18, 'ja', '090-2222-3333', TRUE),
(19, 'de', '080-0000-1111', TRUE),
(20, 'ja', '090-7777-8888', FALSE);

INSERT INTO Pricing (property_id, base_price, cleaning_fee, guest_fee_percentage, host_fee_percentage, currency) 
VALUES
(1, 12000.00, 2000.00, 10.00, 3.00, 'JPY'),
(2, 18000.00, 3000.00, 12.00, 3.00, 'JPY'),
(3, 15000.00, 2500.00, 11.50, 3.00, 'JPY'),
(4, 8000.00, 1500.00, 9.00, 3.00, 'JPY'),
(5, 4500.00, 1000.00, 8.00, 3.00, 'JPY'),
(6, 11000.00, 1800.00, 10.50, 3.00, 'JPY'),
(7, 9500.00, 1600.00, 9.50, 3.00, 'JPY'),
(8, 22000.00, 3500.00, 12.00, 3.00, 'JPY'),
(9, 13000.00, 2200.00, 10.00, 3.00, 'JPY'),
(10, 5000.00, 1200.00, 8.50, 3.00, 'JPY'),
(11, 14000.00, 2400.00, 11.00, 3.00, 'JPY'),
(12, 35000.00, 5000.00, 12.00, 3.00, 'JPY'),
(13, 16000.00, 2800.00, 11.50, 3.00, 'JPY'),
(14, 10500.00, 1900.00, 10.00, 3.00, 'JPY'),
(15, 12500.00, 2100.00, 10.50, 3.00, 'JPY'),
(16, 3000.00, 500.00, 6.00, 3.00, 'JPY'),
(17, 17000.00, 2900.00, 11.00, 3.00, 'JPY'),
(18, 8800.00, 1400.00, 9.00, 3.00, 'JPY'),
(19, 28000.00, 4000.00, 12.00, 3.00, 'JPY'),
(20, 9000.00, 1700.00, 9.50, 3.00, 'JPY');

INSERT INTO House_Rule (property_id, rule_text, rule_category) VALUES
(1, 'No smoking inside the apartment', 'smoking'),
(1, 'No parties or events', 'events'),
(2, 'Shoes off at entrance', 'general'),
(2, 'Quiet hours: 10 PM to 7 AM', 'noise'),
(3, 'Remove snow from entrance in winter', 'maintenance'),
(3, 'No pets allowed', 'pets'),
(4, 'Check-in after 3 PM only', 'check-in'),
(4, 'Separate garbage by category', 'cleaning'),
(5, 'Kitchen use limited to 8 PM', 'kitchen'),
(5, 'Shared bathroom cleaning schedule', 'cleaning'),
(6, 'No loud music after 9 PM', 'noise'),
(6, 'Parking for one car only', 'parking'),
(7, 'Business travelers only', 'guest_type'),
(7, 'No cooking of strong-smelling foods', 'cooking'),
(8, 'Minimum stay: 2 nights', 'booking'),
(8, 'No visitors allowed', 'visitors'),
(9, 'Heating must be turned off when out', 'energy'),
(9, 'Boot dryer use required', 'equipment'),
(10, 'Temple quiet hours observed', 'noise'),
(10, 'Traditional futon setup required', 'bedding');

INSERT INTO Cancellation_Policy (property_id, policy_type, refund_percentage, notice_days) 
VALUES
(1, 'moderate', 50.00, 5),
(2, 'strict', 0.00, 7),
(3, 'flexible', 100.00, 1),
(4, 'moderate', 50.00, 3),
(5, 'flexible', 100.00, 0),
(6, 'moderate', 50.00, 7),
(7, 'strict', 25.00, 14),
(8, 'strict', 0.00, 30),
(9, 'flexible', 100.00, 2),
(10, 'moderate', 50.00, 2),
(11, 'strict', 10.00, 10),
(12, 'strict', 0.00, 60),
(13, 'moderate', 50.00, 14),
(14, 'flexible', 100.00, 7),
(15, 'moderate', 50.00, 10),
(16, 'flexible', 100.00, 0),
(17, 'strict', 20.00, 21),
(18, 'moderate', 50.00, 5),
(19, 'strict', 0.00, 90),
(20, 'flexible', 100.00, 3);

INSERT INTO Photo (property_id, photo_url, caption, display_order, upload_date) VALUES
(1, 'https://example.com/photos/shibuya1.jpg', 'Living room view', 1, '2023-03-16 10:00:00'),
(1, 'https://example.com/photos/shibuya2.jpg', 'Kitchen area', 2, '2023-03-16 10:05:00'),
(2, 'https://example.com/photos/kyoto1.jpg', 'Traditional entrance', 1, '2023-04-21 14:30:00'),
(2, 'https://example.com/photos/kyoto2.jpg', 'Garden view', 2, '2023-04-21 14:35:00'),
(3, 'https://example.com/photos/niseko1.jpg', 'Ski slope view', 1, '2023-05-11 09:15:00'),
(3, 'https://example.com/photos/niseko2.jpg', 'Fireplace area', 2, '2023-05-11 09:20:00'),
(4, 'https://example.com/photos/osaka1.jpg', 'City view balcony', 1, '2023-06-06 11:45:00'),
(4, 'https://example.com/photos/osaka2.jpg', 'Compact kitchen', 2, '2023-06-06 11:50:00'),
(5, 'https://example.com/photos/shinjuku1.jpg', 'Private bedroom', 1, '2023-07-13 16:20:00'),
(5, 'https://example.com/photos/shinjuku2.jpg', 'Shared living room', 2, '2023-07-13 16:25:00'),
(6, 'https://example.com/photos/fukuoka1.jpg', 'Riverside balcony', 1, '2023-08-19 13:10:00'),
(6, 'https://example.com/photos/fukuoka2.jpg', 'Traditional tatami room', 2, '2023-08-19 13:15:00'),
(7, 'https://example.com/photos/nagoya1.jpg', 'Business workspace', 1, '2023-09-23 08:40:00'),
(7, 'https://example.com/photos/nagoya2.jpg', 'Bedroom', 2, '2023-09-23 08:45:00'),
(8, 'https://example.com/photos/yokohama1.jpg', 'Ocean view from balcony', 1, '2023-10-31 15:25:00'),
(8, 'https://example.com/photos/yokohama2.jpg', 'Modern kitchen', 2, '2023-10-31 15:30:00'),
(9, 'https://example.com/photos/sapporo1.jpg', 'Winter garden', 1, '2023-11-15 10:50:00'),
(9, 'https://example.com/photos/sapporo2.jpg', 'Kotatsu dining area', 2, '2023-11-15 10:55:00'),
(10, 'https://example.com/photos/nara1.jpg', 'Temple view window', 1, '2023-12-04 12:35:00'),
(10, 'https://example.com/photos/nara2.jpg', 'Traditional futon setup', 2, '2023-12-04 12:40:00');

INSERT INTO Property_Amenity (property_id, amenity_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 7),
(2, 1), (2, 3), (2, 4), (2, 6),
(3, 1), (3, 3), (3, 4), (3, 5), (3, 6),
(4, 1), (4, 2), (4, 7),
(5, 1), (5, 3), (5, 16), (5, 17),
(6, 1), (6, 2), (6, 3), (6, 4), (6, 11),
(7, 1), (7, 2), (7, 3), (7, 13),
(8, 1), (8, 2), (8, 3), (8, 7), (8, 8), (8, 10),
(9, 1), (9, 3), (9, 4), (9, 5),
(10, 1), (10, 3), (10, 16), (10, 17), (10, 18),
(11, 1), (11, 3), (11, 4), (11, 20),
(12, 1), (12, 2), (12, 3), (12, 4), (12, 5), (12, 6), (12, 9), (12, 10),
(13, 1), (13, 3), (13, 4), (13, 7),
(14, 1), (14, 2), (14, 3), (14, 13),
(15, 1), (15, 2), (15, 3), (15, 7), (15, 16),
(16, 1), (16, 2), (16, 3), (16, 19),
(17, 1), (17, 3), (17, 4), (17, 5), (17, 11),
(18, 1), (18, 2), (18, 3), (18, 7),
(19, 1), (19, 3), (19, 4), (19, 6), (19, 10),
(20, 1), (20, 2), (20, 3), (20, 7), (20, 20);

INSERT INTO Availability (property_id, available_date, is_available, custom_price) 
VALUES
(1, '2024-06-01', TRUE, NULL),
(1, '2024-06-02', TRUE, NULL),
(1, '2024-06-03', FALSE, NULL),
(2, '2024-06-01', TRUE, 20000.00),
(2, '2024-06-02', TRUE, 20000.00),
(3, '2024-06-01', TRUE, NULL),
(3, '2024-06-02', FALSE, NULL),
(4, '2024-06-01', TRUE, 9000.00),
(4, '2024-06-02', TRUE, 9000.00),
(5, '2024-06-01', TRUE, NULL),
(5, '2024-06-02', TRUE, NULL),
(6, '2024-06-01', FALSE, NULL),
(6, '2024-06-02', TRUE, NULL),
(7, '2024-06-01', TRUE, NULL),
(7, '2024-06-02', TRUE, NULL),
(8, '2024-06-01', TRUE, 25000.00),
(8, '2024-06-02', TRUE, 25000.00),
(9, '2024-06-01', TRUE, NULL),
(9, '2024-06-02', TRUE, NULL),
(10, '2024-06-01', TRUE, NULL);

INSERT INTO Income_Calculator (property_id, calculated_date, estimated_monthly_income, occupancy_rate, comparable_properties_avg) VALUES
(1, '2024-05-01 10:00:00', 360000.00, 85.50, 350000.00),
(2, '2024-05-01 10:00:00', 540000.00, 92.30, 500000.00),
(3, '2024-05-01 10:00:00', 450000.00, 78.90, 420000.00),
(4, '2024-05-01 10:00:00', 240000.00, 65.40, 250000.00),
(5, '2024-05-01 10:00:00', 135000.00, 88.20, 140000.00),
(6, '2024-05-01 10:00:00', 330000.00, 82.70, 320000.00),
(7, '2024-05-01 10:00:00', 285000.00, 75.60, 290000.00),
(8, '2024-05-01 10:00:00', 660000.00, 95.10, 600000.00),
(9, '2024-05-01 10:00:00', 390000.00, 80.30, 380000.00),
(10, '2024-05-01 10:00:00', 150000.00, 90.50, 160000.00),
(11, '2024-05-01 10:00:00', 420000.00, 72.80, 400000.00),
(12, '2024-05-01 10:00:00', 1050000.00, 87.60, 980000.00),
(13, '2024-05-01 10:00:00', 480000.00, 69.20, 450000.00),
(14, '2024-05-01 10:00:00', 315000.00, 83.40, 300000.00),
(15, '2024-05-01 10:00:00', 375000.00, 79.10, 360000.00),
(16, '2024-05-01 10:00:00', 90000.00, 96.80, 85000.00),
(17, '2024-05-01 10:00:00', 510000.00, 81.50, 480000.00),
(18, '2024-05-01 10:00:00', 264000.00, 86.70, 250000.00),
(19, '2024-05-01 10:00:00', 840000.00, 94.20, 800000.00),
(20, '2024-05-01 10:00:00', 270000.00, 77.30, 280000.00);

INSERT INTO Payment_Method (guest_id, method_type, card_last_four, expiry_date, is_default) VALUES
(1, 'credit_card', '1234', '2025-12-01', TRUE),
(2, 'paypal', NULL, NULL, TRUE),
(3, 'credit_card', '5678', '2024-06-01', TRUE),
(4, 'debit_card', '9012', '2026-03-01', TRUE),
(5, 'credit_card', '3456', '2025-08-01', FALSE),
(6, 'paypal', NULL, NULL, TRUE),
(7, 'credit_card', '7890', '2027-11-01', TRUE),
(8, 'debit_card', '2345', '2024-09-01', TRUE),
(9, 'credit_card', '6789', '2026-05-01', TRUE),
(10, 'paypal', NULL, NULL, TRUE),
(11, 'credit_card', '0123', '2025-02-01', TRUE),
(12, 'debit_card', '4567', '2024-12-01', TRUE),
(13, 'credit_card', '8901', '2027-07-01', FALSE),
(14, 'paypal', NULL, NULL, TRUE),
(15, 'credit_card', '2345', '2026-10-01', TRUE),
(16, 'debit_card', '6789', '2025-04-01', TRUE),
(17, 'credit_card', '0123', '2028-01-01', TRUE),
(18, 'paypal', NULL, NULL, TRUE),
(19, 'debit_card', '4567', '2024-08-01', TRUE),
(20, 'credit_card', '8901', '2026-06-01', FALSE);

INSERT INTO Booking (property_id, guest_id, check_in_date, check_out_date, num_guests, total_amount, booking_status, booking_date, special_requests) VALUES
(1, 5, '2024-06-15', '2024-06-20', 2, 60000.00, 'confirmed', '2024-05-10 14:30:00', 'Late check-in at 9 PM'),
(2, 6, '2024-07-01', '2024-07-07', 4, 126000.00, 'completed', '2024-04-15 10:15:00', 'Need extra futons'),
(3, 7, '2024-08-10', '2024-08-15', 3, 75000.00, 'pending', '2024-05-20 16:45:00', NULL),
(4, 8, '2024-06-22', '2024-06-25', 1, 24000.00, 'confirmed', '2024-05-12 09:20:00', 'Vegetarian breakfast requested'),
(5, 9, '2024-07-05', '2024-07-08', 2, 13500.00, 'completed', '2024-04-30 13:10:00', NULL),
(6, 10, '2024-08-20', '2024-08-27', 5, 77000.00, 'confirmed', '2024-05-18 11:35:00', 'Anniversary celebration'),
(7, 11, '2024-06-30', '2024-07-02', 2, 19000.00, 'cancelled', '2024-05-05 15:40:00', 'Business trip'),
(8, 12, '2024-07-15', '2024-07-22', 4, 154000.00, 'confirmed', '2024-05-22 08:50:00', 'Ocean view room preferred'),
(9, 13, '2024-08-05', '2024-08-10', 3, 65000.00, 'pending', '2024-05-25 12:15:00', NULL),
(10, 14, '2024-06-18', '2024-06-21', 2, 15000.00, 'completed', '2024-05-08 17:30:00', 'Temple tour guide needed'),
(11, 15, '2024-07-25', '2024-08-01', 6, 98000.00, 'confirmed', '2024-05-15 14:05:00', 'Family reunion'),
(12, 16, '2024-08-12', '2024-08-19', 8, 245000.00, 'pending', '2024-05-28 10:45:00', 'Chef service requested'),
(13, 17, '2024-06-28', '2024-07-03', 4, 80000.00, 'confirmed', '2024-05-14 13:20:00', 'Samurai armor viewing'),
(14, 18, '2024-07-08', '2024-07-10', 3, 21000.00, 'completed', '2024-05-03 16:55:00', NULL),
(15, 19, '2024-08-22', '2024-08-28', 4, 75000.00, 'confirmed', '2024-05-19 09:40:00', 'Peace Park tour arrangement'),
(16, 20, '2024-06-25', '2024-06-27', 1, 6000.00, 'cancelled', '2024-05-07 11:25:00', 'First time capsule hotel'),
(17, 1, '2024-07-30', '2024-08-05', 5, 85000.00, 'pending', '2024-05-30 15:10:00', 'Beach equipment needed'),
(18, 2, '2024-08-15', '2024-08-18', 3, 26400.00, 'confirmed', '2024-05-16 12:50:00', 'Castle photography permission'),
(19, 3, '2024-09-01', '2024-09-10', 8, 252000.00, 'confirmed', '2024-05-24 08:35:00', 'Traditional tea ceremony'),
(20, 4, '2024-07-12', '2024-07-14', 2, 18000.00, 'completed', '2024-05-01 14:20:00', 'Harbor cruise tickets');

INSERT INTO Payment (booking_id, payment_method_id, amount, payment_date, payment_status, transaction_reference) VALUES
(1, 1, 60000.00, '2024-05-10 14:45:00', 'completed', 'TRX-20240510-001'),
(2, 6, 126000.00, '2024-04-15 10:30:00', 'completed', 'TRX-20240415-002'),
(3, 7, 75000.00, '2024-05-20 17:00:00', 'pending', 'TRX-20240520-003'),
(4, 8, 24000.00, '2024-05-12 09:35:00', 'completed', 'TRX-20240512-004'),
(5, 9, 13500.00, '2024-04-30 13:25:00', 'completed', 'TRX-20240430-005'),
(6, 10, 77000.00, '2024-05-18 11:50:00', 'completed', 'TRX-20240518-006'),
(7, 11, 19000.00, '2024-05-05 15:55:00', 'refunded', 'TRX-20240505-007'),
(8, 12, 154000.00, '2024-05-22 09:05:00', 'completed', 'TRX-20240522-008'),
(9, 13, 65000.00, '2024-05-25 12:30:00', 'pending', 'TRX-20240525-009'),
(10, 14, 15000.00, '2024-05-08 17:45:00', 'completed', 'TRX-20240508-010'),
(11, 15, 98000.00, '2024-05-15 14:20:00', 'completed', 'TRX-20240515-011'),
(12, 16, 245000.00, '2024-05-28 11:00:00', 'pending', 'TRX-20240528-012'),
(13, 17, 80000.00, '2024-05-14 13:35:00', 'completed', 'TRX-20240514-013'),
(14, 18, 21000.00, '2024-05-03 17:10:00', 'completed', 'TRX-20240503-014'),
(15, 19, 75000.00, '2024-05-19 09:55:00', 'completed', 'TRX-20240519-015'),
(16, 20, 6000.00, '2024-05-07 11:40:00', 'refunded', 'TRX-20240507-016'),
(17, 1, 85000.00, '2024-05-30 15:25:00', 'pending', 'TRX-20240530-017'),
(18, 2, 26400.00, '2024-05-16 13:05:00', 'completed', 'TRX-20240516-018'),
(19, 3, 252000.00, '2024-05-24 08:50:00', 'completed', 'TRX-20240524-019'),
(20, 4, 18000.00, '2024-05-01 14:35:00', 'completed', 'TRX-20240501-020');

INSERT INTO Payout (booking_id, host_id, amount, payout_date, payout_status) VALUES
(1, 1, 58200.00, '2024-06-21 10:00:00', 'scheduled'),
(2, 2, 122220.00, '2024-07-08 10:00:00', 'completed'),
(3, 3, 72750.00, NULL, 'scheduled'),
(4, 4, 23280.00, '2024-06-26 10:00:00', 'scheduled'),
(5, 5, 13095.00, '2024-07-09 10:00:00', 'completed'),
(6, 6, 74690.00, '2024-08-28 10:00:00', 'scheduled'),
(7, 7, 18430.00, NULL, 'held'),
(8, 8, 149380.00, '2024-07-23 10:00:00', 'scheduled'),
(9, 9, 63050.00, NULL, 'scheduled'),
(10, 10, 14550.00, '2024-06-22 10:00:00', 'completed'),
(11, 11, 95060.00, '2024-08-02 10:00:00', 'scheduled'),
(12, 12, 237650.00, NULL, 'scheduled'),
(13, 13, 77600.00, '2024-07-04 10:00:00', 'scheduled'),
(14, 14, 20370.00, '2024-07-11 10:00:00', 'completed'),
(15, 15, 72750.00, '2024-08-29 10:00:00', 'scheduled'),
(16, 16, 5820.00, NULL, 'held'),
(17, 17, 82450.00, NULL, 'scheduled'),
(18, 18, 25608.00, '2024-08-19 10:00:00', 'scheduled'),
(19, 19, 244440.00, '2024-09-11 10:00:00', 'scheduled'),
(20, 20, 17460.00, '2024-07-15 10:00:00', 'completed');

INSERT INTO Review (booking_id, reviewer_id, reviewee_id, review_type, rating_overall, rating_cleanliness, rating_communication, rating_accuracy, rating_location, rating_value, review_text, review_date, is_public) VALUES
(2, 6, 2, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Perfect traditional experience in Kyoto!', '2024-07-08 14:00:00', TRUE),
(2, 2, 6, 'host_to_guest', 5, NULL, 5, NULL, NULL, NULL, 'Excellent guests, very respectful of the property.', '2024-07-08 15:30:00', TRUE),
(5, 9, 5, 'guest_to_host', 4, 3, 5, 4, 5, 4, 'Good value for Shinjuku location', '2024-07-09 10:00:00', TRUE),
(5, 5, 9, 'host_to_guest', 5, NULL, 5, NULL, NULL, NULL, 'Very clean and quiet guest.', '2024-07-09 11:00:00', TRUE),
(10, 14, 10, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Magical temple stay experience', '2024-06-22 09:00:00', TRUE),
(10, 10, 14, 'host_to_guest', 5, NULL, 5, NULL, NULL, NULL, 'Wonderful guests interested in culture.', '2024-06-22 10:00:00', TRUE),
(14, 18, 14, 'guest_to_host', 4, 4, 5, 4, 4, 4, 'Modern loft with good workspace', '2024-07-11 12:00:00', TRUE),
(14, 14, 18, 'host_to_guest', 4, NULL, 4, NULL, NULL, NULL, 'Good communication, left place clean.', '2024-07-11 13:00:00', TRUE),
(20, 4, 20, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Beautiful harbor views from room', '2024-07-15 11:00:00', TRUE),
(20, 20, 4, 'host_to_guest', 5, NULL, 5, NULL, NULL, NULL, 'Perfect guests, welcome back anytime.', '2024-07-15 12:00:00', TRUE),
(1, 5, 1, 'guest_to_host', 4, 4, 5, 4, 5, 4, 'Great Shibuya location', NULL, TRUE),
(4, 8, 4, 'guest_to_host', 3, 3, 4, 3, 5, 3, 'Small but functional', NULL, TRUE),
(6, 10, 6, 'guest_to_host', 5, 5, 5, 5, 4, 5, 'Perfect for family vacation', NULL, TRUE),
(8, 12, 8, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Luxury experience worth every yen', NULL, TRUE),
(11, 15, 11, 'guest_to_host', 4, 4, 5, 4, 4, 4, 'Historic house with modern amenities', NULL, TRUE),
(13, 17, 13, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Samurai house exceeded expectations', NULL, TRUE),
(15, 19, 15, 'guest_to_host', 4, 4, 5, 4, 5, 4, 'Convenient for Peace Park visit', NULL, TRUE),
(18, 2, 18, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Castle view was spectacular', NULL, TRUE),
(19, 3, 19, 'guest_to_host', 5, 5, 5, 5, 5, 5, 'Authentic ryokan experience', NULL, TRUE),
(7, 11, 7, 'guest_to_host', 2, 2, 3, 2, 4, 2, 'Cancellation issues', NULL, FALSE);

INSERT INTO Review_Response (review_id, responder_id, response_text, response_date) VALUES
(3, 5, 'Thank you for your feedback. We have addressed the cleanliness concerns.', '2024-07-09 14:00:00'),
(7, 14, 'Appreciate your review. We are improving our workspace setup.', '2024-07-11 15:00:00'),
(11, 4, 'Sorry to hear about the issues. We have updated our kitchen supplies.', '2024-05-12 16:00:00'),
(16, 17, 'Thank you! We are happy you enjoyed the samurai history.', NULL),
(19, 3, 'Arigatou gozaimasu! We hope to welcome you again.', NULL);

INSERT INTO Conversation (booking_id, participant1_id, participant2_id, created_date, last_message_date) VALUES
(1, 5, 1, '2024-05-10 14:30:00', '2024-05-11 10:15:00'),
(2, 6, 2, '2024-04-15 10:15:00', '2024-04-16 14:30:00'),
(3, 7, 3, '2024-05-20 16:45:00', '2024-05-21 09:20:00'),
(4, 8, 4, '2024-05-12 09:20:00', '2024-05-13 16:45:00'),
(5, 9, 5, '2024-04-30 13:10:00', '2024-05-01 11:30:00'),
(6, 10, 6, '2024-05-18 11:35:00', '2024-05-19 15:20:00'),
(7, 11, 7, '2024-05-05 15:40:00', '2024-05-06 10:10:00'),
(8, 12, 8, '2024-05-22 08:50:00', '2024-05-23 14:25:00'),
(9, 13, 9, '2024-05-25 12:15:00', '2024-05-26 09:40:00'),
(10, 14, 10, '2024-05-08 17:30:00', '2024-05-09 13:15:00'),
(11, 15, 11, '2024-05-15 14:05:00', '2024-05-16 16:50:00'),
(12, 16, 12, '2024-05-28 10:45:00', '2024-05-29 11:35:00'),
(13, 17, 13, '2024-05-14 13:20:00', '2024-05-15 15:10:00'),
(14, 18, 14, '2024-05-03 16:55:00', '2024-05-04 12:40:00'),
(15, 19, 15, '2024-05-19 09:40:00', '2024-05-20 14:20:00'),
(16, 20, 16, '2024-05-07 11:25:00', '2024-05-08 10:05:00'),
(17, 1, 17, '2024-05-30 15:10:00', '2024-05-31 13:50:00'),
(18, 2, 18, '2024-05-16 12:50:00', '2024-05-17 11:30:00'),
(19, 3, 19, '2024-05-24 08:35:00', '2024-05-25 15:15:00'),
(20, 4, 20, '2024-05-01 14:20:00', '2024-05-02 12:10:00');

INSERT INTO Message (conversation_id, sender_id, message_text, sent_date, is_read) VALUES
(1, 5, 'Hello, I would like to check in at 9 PM. Is that possible?', '2024-05-10 14:30:00', TRUE),
(1, 1, 'Yes, late check-in is available. I will leave key in lockbox.', '2024-05-10 15:00:00', TRUE),
(1, 5, 'Thank you! Where is the lockbox located?', '2024-05-10 15:30:00', TRUE),
(1, 1, 'Next to main entrance, code will be sent day before arrival.', '2024-05-11 10:15:00', TRUE),
(2, 6, 'Do you have extra futons available for our stay?', '2024-04-15 10:15:00', TRUE),
(2, 2, 'Yes, we can provide 2 extra futons. No extra charge.', '2024-04-15 11:00:00', TRUE),
(2, 6, 'Perfect! We are 4 adults. Thank you.', '2024-04-16 14:30:00', TRUE),
(3, 7, 'Is the ski equipment rental nearby?', '2024-05-20 16:45:00', TRUE),
(3, 3, 'Yes, 5-minute walk to rental shop. I can give you discount coupon.', '2024-05-21 09:20:00', TRUE),
(4, 8, 'Can you arrange vegetarian breakfast?', '2024-05-12 09:20:00', TRUE),
(4, 4, 'Yes, vegetarian options available. Please specify preferences.', '2024-05-12 10:00:00', TRUE),
(4, 8, 'No fish or meat products. Thank you.', '2024-05-13 16:45:00', TRUE),
(5, 9, 'What is the exact address?', '2024-04-30 13:10:00', TRUE),
(5, 5, 'Address sent to your email. Building has security code 1234.', '2024-05-01 11:30:00', TRUE),
(6, 10, 'We are celebrating anniversary. Any restaurant recommendations?', '2024-05-18 11:35:00', TRUE),
(6, 6, 'French restaurant "La Mer" nearby is excellent for celebrations.', '2024-05-19 15:20:00', TRUE),
(7, 11, 'Need to cancel due to business trip change.', '2024-05-05 15:40:00', TRUE),
(7, 7, 'Understood. Please check cancellation policy for refund details.', '2024-05-06 10:10:00', TRUE),
(8, 12, 'Can we get room with best ocean view?', '2024-05-22 08:50:00', TRUE),
(8, 8, 'Room 801 has best view. I will assign it to your booking.', '2024-05-23 14:25:00', TRUE),
(9, 13, 'What time is check-in?', '2024-05-25 12:15:00', TRUE),
(9, 9, 'Check-in from 3 PM. Early check-in possible if room ready.', '2024-05-26 09:40:00', TRUE);

INSERT INTO Social_Connection (user_id, platform, platform_user_id, connection_date) VALUES
(1, 'facebook', 'sato.taro.fb', '2023-02-15 10:00:00'),
(2, 'instagram', 'suzuki.hanako.ig', '2023-03-20 14:30:00'),
(3, 'twitter', 'takahashi_yuki_tw', '2023-04-10 09:15:00'),
(4, 'facebook', 'tanaka.ryo.fb', '2023-05-05 11:45:00'),
(5, 'linkedin', 'watanabe.akira.li', '2023-06-12 16:20:00'),
(6, 'instagram', 'ito.mai.ig', '2023-07-18 13:10:00'),
(7, 'facebook', 'yamamoto.kenji.fb', '2023-08-22 08:40:00'),
(8, 'twitter', 'nakamura_sakura_tw', '2023-09-30 15:25:00'),
(9, 'linkedin', 'kobayashi.hiroshi.li', '2023-10-14 10:50:00'),
(10, 'instagram', 'kato.megumi.ig', '2023-11-03 12:35:00'),
(11, 'facebook', 'yoshida.takeshi.fb', '2023-12-08 09:00:00'),
(12, 'twitter', 'yamada_naomi_tw', '2024-01-25 14:15:00'),
(13, 'instagram', 'sasaki.kaito.ig', '2024-02-10 11:30:00'),
(14, 'facebook', 'matsumoto.yui.fb', '2024-03-15 13:20:00'),
(15, 'linkedin', 'inoue.daiki.li', '2024-04-12 08:50:00'),
(16, 'instagram', 'kimura.emi.ig', '2024-04-25 15:35:00'),
(17, 'twitter', 'hayashi_ryota_tw', '2024-05-10 12:10:00'),
(18, 'facebook', 'shimizu.miyuki.fb', '2024-05-22 09:55:00'),
(19, 'linkedin', 'yamazaki.takumi.li', '2024-06-01 10:00:00'),
(20, 'instagram', 'mori.rika.ig', '2024-06-15 14:30:00');

INSERT INTO Verification_Document (user_id, document_type, document_url, upload_date, verification_status, verified_by_admin_id, verified_date) VALUES
(1, 'passport', 'https://example.com/docs/sato_passport.jpg', '2023-01-20 10:00:00', 'approved', 1, '2023-01-22 14:00:00'),
(2, 'government_id', 'https://example.com/docs/suzuki_id.jpg', '2023-02-25 14:30:00', 'approved', 1, '2023-02-27 10:30:00'),
(3, 'drivers_license', 'https://example.com/docs/takahashi_license.jpg', '2023-03-15 09:15:00', 'approved', 2, '2023-03-17 16:45:00'),
(4, 'passport', 'https://example.com/docs/tanaka_passport.jpg', '2023-04-10 11:45:00', 'approved', 2, '2023-04-12 09:20:00'),
(5, 'government_id', 'https://example.com/docs/watanabe_id.jpg', '2023-05-20 16:20:00', 'pending', NULL, NULL),
(6, 'drivers_license', 'https://example.com/docs/ito_license.jpg', '2023-06-25 13:10:00', 'approved', 1, '2023-06-27 11:35:00'),
(7, 'passport', 'https://example.com/docs/yamamoto_passport.jpg', '2023-07-30 08:40:00', 'approved', 2, '2023-08-01 15:40:00'),
(8, 'government_id', 'https://example.com/docs/nakamura_id.jpg', '2023-08-20 15:25:00', 'approved', 1, '2023-08-22 10:15:00'),
(9, 'drivers_license', 'https://example.com/docs/kobayashi_license.jpg', '2023-09-15 10:50:00', 'approved', 2, '2023-09-17 14:25:00'),
(10, 'passport', 'https://example.com/docs/kato_passport.jpg', '2023-10-08 12:35:00', 'approved', 1, '2023-10-10 16:50:00'),
(11, 'government_id', 'https://example.com/docs/yoshida_id.jpg', '2023-11-12 09:00:00', 'approved', 2, '2023-11-14 13:20:00'),
(12, 'drivers_license', 'https://example.com/docs/yamada_license.jpg', '2024-01-30 14:15:00', 'approved', 1, '2024-02-01 09:40:00'),
(13, 'passport', 'https://example.com/docs/sasaki_passport.jpg', '2024-02-15 11:30:00', 'rejected', 2, '2024-02-17 15:10:00'),
(14, 'government_id', 'https://example.com/docs/matsumoto_id.jpg', '2024-03-20 13:20:00', 'approved', 1, '2024-03-22 11:30:00'),
(15, 'drivers_license', 'https://example.com/docs/inoue_license.jpg', '2024-04-17 08:50:00', 'approved', 2, '2024-04-19 14:20:00'),
(16, 'passport', 'https://example.com/docs/kimura_passport.jpg', '2024-04-30 15:35:00', 'pending', NULL, NULL),
(17, 'government_id', 'https://example.com/docs/hayashi_id.jpg', '2024-05-15 12:10:00', 'approved', 1, '2024-05-17 10:05:00'),
(18, 'drivers_license', 'https://example.com/docs/shimizu_license.jpg', '2024-05-27 09:55:00', 'approved', 2, '2024-05-29 13:45:00'),
(19, 'passport', 'https://example.com/docs/yamazaki_passport.jpg', '2024-06-06 10:00:00', 'pending', NULL, NULL),
(20, 'government_id', 'https://example.com/docs/mori_id.jpg', '2024-06-20 14:30:00', 'rejected', 1, '2024-06-22 16:30:00');

INSERT INTO Dispute (booking_id, complainant_id, respondent_id, admin_id, dispute_reason, dispute_status, created_date, resolution_date, resolution_notes) VALUES
(4, 8, 4, NULL, 'Vegetarian breakfast contained fish', 'closed', '2024-05-14 12:00:00', '2024-05-16 14:00:00', 'Full refund for breakfast provided'),
(5, 9, 5, NULL, 'Shared bathroom was not clean', 'closed', '2024-05-02 10:00:00', '2024-05-04 11:00:00', 'Cleaning fee refunded'),
(10, 14, 10, NULL, 'Temple tour guide spoke only Japanese', 'closed', '2024-05-10 09:00:00', '2024-05-12 10:00:00', 'Partial tour cost refunded'),
(16, 20, 16, 2, 'Capsule hotel not as described in photos', 'open', '2024-05-09 09:30:00', NULL, NULL),
(16, 16, 20, 2, 'Guest damaged property during stay', 'open', '2024-05-09 10:30:00', NULL, NULL),
(7, 11, 7, 1, 'Host refused refund despite business trip cancellation', 'resolved', '2024-05-07 10:00:00', '2024-05-10 14:00:00', 'Partial refund of 50% issued per policy'),
(7, 7, 11, 1, 'Guest cancelled last minute causing income loss', 'resolved', '2024-05-07 11:00:00', '2024-05-10 14:00:00', 'Both parties agreed to 50% refund'),
(3, 7, 3, NULL, 'Host not responding to ski equipment questions', 'in_progress', '2024-05-22 14:00:00', NULL, NULL),
(12, 16, 12, NULL, 'Chef service not provided as promised', 'in_progress', '2024-05-30 11:00:00', NULL, NULL),
(9, 13, 9, NULL, 'Early check-in denied despite agreement', 'open', '2024-05-27 15:00:00', NULL, NULL),
(17, 1, 17, NULL, 'Beach equipment was broken upon arrival', 'open', '2024-06-01 10:00:00', NULL, NULL),
(1, 5, 1, NULL, 'Lockbox code not provided on time', 'open', '2024-05-12 08:00:00', NULL, NULL),
(6, 10, 6, NULL, 'Restaurant recommendation was closed', 'open', '2024-05-20 16:00:00', NULL, NULL),
(8, 12, 8, NULL, 'Ocean view room not assigned as promised', 'open', '2024-05-24 09:00:00', NULL, NULL),
(11, 15, 11, NULL, 'Historic house had modern TV broken', 'open', '2024-05-17 14:00:00', NULL, NULL),
(13, 17, 13, NULL, 'Samurai armor viewing not available', 'open', '2024-05-16 11:00:00', NULL, NULL),
(15, 19, 15, NULL, 'Peace Park tour guide never showed', 'open', '2024-05-21 13:00:00', NULL, NULL),
(18, 2, 18, NULL, 'Castle photography permission denied', 'open', '2024-05-18 15:00:00', NULL, NULL),
(19, 3, 19, NULL, 'Traditional tea ceremony was shortened', 'open', '2024-05-26 10:00:00', NULL, NULL),
(20, 4, 20, NULL, 'Harbor cruise tickets were expired', 'closed', '2024-05-03 14:00:00', '2024-05-05 15:00:00', 'New tickets provided');

INSERT INTO Booking_Guest_Payment (booking_id, guest_id, payment_id) VALUES
(1, 5, 1),
(2, 6, 2),
(3, 7, 3),
(4, 8, 4),
(5, 9, 5),
(6, 10, 6),
(7, 11, 7),
(8, 12, 8),
(9, 13, 9),
(10, 14, 10),
(11, 15, 11),
(12, 16, 12),
(13, 17, 13),
(14, 18, 14),
(15, 19, 15),
(16, 20, 16),
(17, 1, 17),
(18, 2, 18),
(19, 3, 19),
(20, 4, 20);

INSERT INTO Booking_Host_Payout (booking_id, host_id, payout_id) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10),
(11, 11, 11),
(12, 12, 12),
(13, 13, 13),
(14, 14, 14),
(15, 15, 15),
(16, 16, 16),
(17, 17, 17),
(18, 18, 18),
(19, 19, 19),
(20, 20, 20);


-- 1. User Table
SELECT user_id, email, first_name, last_name, is_verified 
FROM Users
WHERE registration_date > '2023-01-01'
LIMIT 3;

-- 2. Host_Profile Table  
SELECT user_id, response_rate, is_superhost, government_id_verified 
FROM Host_Profile 
WHERE response_rate > 90
LIMIT 3;

-- 3. Guest_Profile Table
SELECT user_id, preferred_language, identity_verified 
FROM Guest_Profile 
WHERE identity_verified = TRUE
LIMIT 3;

-- 4. Property Table
SELECT property_id, host_id, title, property_type, max_guests, is_active 
FROM Property 
WHERE is_active = TRUE
LIMIT 3;

-- 5. Address Table
SELECT property_id, city, country, latitude, longitude 
FROM Address 
WHERE country = 'Japan'
LIMIT 3;

-- 6. Amenity Table
SELECT amenity_id, amenity_name, category 
FROM Amenity 
WHERE category = 'basic'
LIMIT 3;

-- 7. Property_Amenity Table
SELECT property_id, amenity_id 
FROM Property_Amenity 
WHERE property_id = 1
LIMIT 3;

-- 8. Photo Table
SELECT property_id, photo_url, caption, display_order 
FROM Photo 
WHERE property_id = 1
ORDER BY display_order
LIMIT 3;

-- 9. Pricing Table
SELECT property_id, base_price, cleaning_fee, currency 
FROM Pricing 
WHERE base_price > 10000
LIMIT 3;

-- 10. Availability Table
SELECT property_id, available_date, is_available, custom_price 
FROM Availability 
WHERE property_id = 1 AND is_available = TRUE
LIMIT 3;

-- 11. Booking Table
SELECT booking_id, property_id, guest_id, check_in_date, booking_status 
FROM Booking 
WHERE booking_status = 'confirmed'
LIMIT 3;

-- 12. Payment Table
SELECT payment_id, booking_id, amount, payment_status 
FROM Payment 
WHERE payment_status = 'completed'
LIMIT 3;

-- 13. Payment_Method Table
SELECT guest_id, method_type, is_default 
FROM Payment_Method 
WHERE is_default = TRUE
LIMIT 3;

-- 14. Payout Table
SELECT booking_id, host_id, amount, payout_status 
FROM Payout 
WHERE payout_status = 'scheduled'
LIMIT 3;

-- 15. Review Table
SELECT booking_id, reviewer_id, reviewee_id, rating_overall, review_type 
FROM Review 
WHERE rating_overall = 5
LIMIT 3;

-- 16. Review_Response Table
SELECT review_id, responder_id, response_date 
FROM Review_Response 
WHERE response_date IS NOT NULL
LIMIT 3;

-- 17. Conversation Table
SELECT conversation_id, booking_id, participant1_id, participant2_id 
FROM Conversation 
WHERE booking_id IS NOT NULL
LIMIT 3;

-- 18. Message Table
SELECT conversation_id, sender_id, sent_date, is_read 
FROM Message 
WHERE is_read = TRUE
LIMIT 3;

-- 19. Social_Connection Table
SELECT user_id, platform, connection_date 
FROM Social_Connection 
WHERE platform = 'facebook'
LIMIT 3;

-- 20. House_Rule Table
SELECT property_id, rule_text, rule_category 
FROM House_Rule 
WHERE rule_category = 'noise'
LIMIT 3;

-- 21. Cancellation_Policy Table
SELECT property_id, policy_type, refund_percentage 
FROM Cancellation_Policy 
WHERE policy_type = 'flexible'
LIMIT 3;

-- 22. Dispute Table
SELECT booking_id, complainant_id, dispute_status 
FROM Dispute 
WHERE dispute_status = 'open'
LIMIT 3;

-- 23. Income_Calculator Table
SELECT property_id, estimated_monthly_income, occupancy_rate 
FROM Income_Calculator 
WHERE estimated_monthly_income > 300000
LIMIT 3;

-- 24. Verification_Document Table
SELECT user_id, document_type, verification_status 
FROM Verification_Document 
WHERE verification_status = 'approved'
LIMIT 3;

-- 25. Booking_Guest_Payment Table
SELECT booking_id, guest_id, payment_id 
FROM Booking_Guest_Payment 
WHERE booking_id = 1
LIMIT 3;

-- 26. Booking_Host_Payout Table
SELECT booking_id, host_id, payout_id 
FROM Booking_Host_Payout 
WHERE booking_id = 1

LIMIT 3;
