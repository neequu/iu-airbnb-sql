
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

-- Complex queries
-- Query 1: Complete booking financial flow (booking → payment → payout workflow)
SELECT 
    b.booking_id,
    CONCAT(g.first_name, ' ', g.last_name) AS guest_name,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    p.title AS property_title,
    b.check_in_date,
    b.check_out_date,
    b.total_amount AS booking_total,
    b.booking_status,
    pm.amount AS payment_amount,
    pm.payment_status,
    pm.payment_date,
    po.amount AS payout_amount,
    po.payout_status,
    po.payout_date,
    CASE 
        WHEN po.payout_status = 'completed' THEN 'Funds transferred to host'
        WHEN po.payout_status = 'scheduled' THEN 'Awaiting payout schedule'
        WHEN po.payout_status = 'held' THEN 'Payment held due to dispute'
        ELSE 'Processing'
    END AS payout_status_description
FROM Booking b
JOIN Users g ON b.guest_id = g.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN Users h ON p.host_id = h.user_id
LEFT JOIN Payment pm ON b.booking_id = pm.booking_id
LEFT JOIN Payout po ON b.booking_id = po.booking_id
WHERE b.booking_status IN ('confirmed', 'completed')
ORDER BY b.booking_date DESC
LIMIT 20;


-- Query 2: Host performance dashboard (host profile → properties → bookings → reviews workflow)
SELECT 
    h.user_id AS host_id,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    hp.hosting_since,
    hp.is_superhost,
    hp.response_rate,
    hp.response_time,
    COUNT(DISTINCT p.property_id) AS total_properties,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    COUNT(DISTINCT r.review_id) AS total_reviews_received,
    ROUND(AVG(r.rating_overall), 2) AS avg_overall_rating,
    ROUND(AVG(r.rating_cleanliness), 2) AS avg_cleanliness,
    ROUND(AVG(r.rating_communication), 2) AS avg_communication,
    ROUND(AVG(r.rating_accuracy), 2) AS avg_accuracy,
    ROUND(AVG(r.rating_location), 2) AS avg_location,
    ROUND(AVG(r.rating_value), 2) AS avg_value,
    COUNT(DISTINCT rr.response_id) AS reviews_with_response,
    ROUND(COUNT(DISTINCT rr.response_id) * 100.0 / NULLIF(COUNT(DISTINCT r.review_id), 0), 2) AS response_rate_to_reviews,
    ROUND(AVG(ic.estimated_monthly_income), 2) AS avg_estimated_income
FROM Users h
JOIN Host_Profile hp ON h.user_id = hp.user_id
LEFT JOIN Property p ON h.user_id = p.host_id AND p.is_active = true
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON b.booking_id = r.booking_id AND r.reviewee_id = h.user_id
LEFT JOIN Review_Response rr ON r.review_id = rr.review_id
LEFT JOIN Income_Calculator ic ON p.property_id = ic.property_id
WHERE h.is_verified = true
GROUP BY h.user_id, h.first_name, h.last_name, hp.hosting_since, 
         hp.is_superhost, hp.response_rate, hp.response_time
HAVING COUNT(DISTINCT p.property_id) > 0
ORDER BY avg_overall_rating DESC NULLS LAST, total_bookings DESC;


-- Query 3: Guest booking history and review analysis (guest profile → bookings → payment methods → reviews workflow)
SELECT 
    g.user_id AS guest_id,
    CONCAT(g.first_name, ' ', g.last_name) AS guest_name,
    gp.identity_verified,
    gp.preferred_language,
    b.booking_id,
    p.title AS property_title,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    b.check_in_date,
    b.check_out_date,
    b.num_guests,
    b.total_amount,
    b.booking_status,
    pm.method_type,
    pm.card_last_four,
    pay.payment_status,
    pay.payment_date,
    r.review_date AS guest_review_date,
    r.rating_overall AS guest_rating,
    r.rating_cleanliness,
    r.rating_communication,
    r.rating_accuracy,
    r.rating_location,
    r.rating_value,
    LEFT(r.review_text, 100) AS review_preview,
    rr.response_text AS host_response,
    rr.response_date AS host_response_date,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - b.booking_date)) AS days_since_booking,
    COUNT(*) OVER (PARTITION BY g.user_id) AS total_bookings_by_guest
FROM Users g
JOIN Guest_Profile gp ON g.user_id = gp.user_id
JOIN Booking b ON g.user_id = b.guest_id
JOIN Property p ON b.property_id = p.property_id
JOIN Users h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
LEFT JOIN Payment_Method pm ON pay.payment_method_id = pm.payment_method_id
LEFT JOIN Review r ON b.booking_id = r.booking_id AND r.reviewer_id = g.user_id
LEFT JOIN Review_Response rr ON r.review_id = rr.review_id
ORDER BY b.booking_date DESC, g.user_id;