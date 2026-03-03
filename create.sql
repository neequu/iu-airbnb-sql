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