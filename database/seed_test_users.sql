-- Seed Test Users for Wedding Planner App
-- Run this script to create test accounts for development

-- =====================================================
-- TEST USERS
-- Password for all test users: Test@123
-- bcrypt hash: $2b$10$rZwR8KBXV.R3oHxHFVX9K.1234567890abcdefghijklmnopqrst
-- =====================================================

-- Test Vendor User
INSERT INTO users (id, email, phone, password_hash, user_type, is_active, email_verified)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'vendor@test.com',
    '+1234567890',
    '$2a$10$n6HDoeTT1ubDFp1oXG4quu/pHuXexdAuDxQzXvAgAjApAG/O.0wT6',  -- Test@123
    'vendor',
    true,
    true
) ON CONFLICT (email) DO NOTHING;

-- Test Vendor Profile
INSERT INTO vendors (
    id, user_id, business_name, category_id, description,
    location_city, location_country, price_range,
    rating_avg, review_count, status, commission_rate,
    is_verified, is_featured, response_time_hours, weddings_completed
)
SELECT
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Dream Photography Studio',
    (SELECT id FROM categories WHERE name = 'Photography' LIMIT 1),
    'Professional wedding photography capturing your special moments with artistic flair.',
    'New York',
    'USA',
    '$$$',
    4.8,
    127,
    'approved',
    10.00,
    true,
    true,
    2,
    89
WHERE NOT EXISTS (
    SELECT 1 FROM vendors WHERE user_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
);

-- Test Vendor Packages
INSERT INTO vendor_packages (id, vendor_id, name, description, price, features, duration_hours, is_popular, is_active)
SELECT
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'Silver Package',
    'Perfect for intimate weddings',
    1500.00,
    '["4 hours coverage", "100 edited photos", "Online gallery", "1 photographer"]'::jsonb,
    4,
    false,
    true
WHERE NOT EXISTS (
    SELECT 1 FROM vendor_packages WHERE id = 'c3d4e5f6-a7b8-9012-cdef-345678901234'
);

INSERT INTO vendor_packages (id, vendor_id, name, description, price, features, duration_hours, is_popular, is_active)
SELECT
    'd4e5f6a7-b8c9-0123-defa-456789012345',
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'Gold Package',
    'Our most popular choice for weddings',
    2500.00,
    '["8 hours coverage", "300 edited photos", "Online gallery", "2 photographers", "Engagement shoot", "Photo album"]'::jsonb,
    8,
    true,
    true
WHERE NOT EXISTS (
    SELECT 1 FROM vendor_packages WHERE id = 'd4e5f6a7-b8c9-0123-defa-456789012345'
);

INSERT INTO vendor_packages (id, vendor_id, name, description, price, features, duration_hours, is_popular, is_active)
SELECT
    'e5f6a7b8-c9d0-1234-efab-567890123456',
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'Platinum Package',
    'Complete coverage for your dream wedding',
    4000.00,
    '["Full day coverage", "500+ edited photos", "Online gallery", "2 photographers", "Engagement shoot", "Premium album", "Video highlights", "Drone shots"]'::jsonb,
    12,
    false,
    true
WHERE NOT EXISTS (
    SELECT 1 FROM vendor_packages WHERE id = 'e5f6a7b8-c9d0-1234-efab-567890123456'
);

-- Test Couple User
INSERT INTO users (id, email, phone, password_hash, user_type, is_active, email_verified)
VALUES (
    'f6a7b8c9-d0e1-2345-fab0-678901234567',
    'couple@test.com',
    '+1987654321',
    '$2a$10$n6HDoeTT1ubDFp1oXG4quu/pHuXexdAuDxQzXvAgAjApAG/O.0wT6',  -- Test@123
    'couple',
    true,
    true
) ON CONFLICT (email) DO NOTHING;

-- Test Wedding for Couple
INSERT INTO weddings (
    id, user_id, partner1_name, partner2_name, wedding_date,
    budget_total, budget_spent, currency, guest_count_expected,
    style_preferences, cultural_traditions, region, planning_progress
)
SELECT
    'a7b8c9d0-e1f2-3456-ab01-789012345678',
    'f6a7b8c9-d0e1-2345-fab0-678901234567',
    'Emma',
    'James',
    '2026-09-15',
    50000.00,
    12500.00,
    'USD',
    150,
    ARRAY['Modern', 'Romantic'],
    ARRAY['Western'],
    'North America',
    35
WHERE NOT EXISTS (
    SELECT 1 FROM weddings WHERE user_id = 'f6a7b8c9-d0e1-2345-fab0-678901234567'
);

-- Test Booking (couple booked vendor)
INSERT INTO bookings (
    id, wedding_id, vendor_id, package_id, status,
    booking_date, total_amount, deposit_amount, deposit_paid,
    commission_rate, commission_amount, vendor_payout, couple_notes
)
SELECT
    'b8c9d0e1-f2a3-4567-bc12-890123456789',
    'a7b8c9d0-e1f2-3456-ab01-789012345678',
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'd4e5f6a7-b8c9-0123-defa-456789012345',
    'pending',
    '2026-09-15',
    2500.00,
    500.00,
    false,
    10.00,
    250.00,
    2250.00,
    'Looking forward to working with you! We love your portfolio.'
WHERE NOT EXISTS (
    SELECT 1 FROM bookings WHERE id = 'b8c9d0e1-f2a3-4567-bc12-890123456789'
);

-- =====================================================
-- DONE
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Test users seeded successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📧 Test Accounts (Password: Test@123):';
    RAISE NOTICE '   Vendor: vendor@test.com';
    RAISE NOTICE '   Couple: couple@test.com';
    RAISE NOTICE '';
    RAISE NOTICE '🏪 Vendor "Dream Photography Studio" with 3 packages';
    RAISE NOTICE '💒 Wedding for Emma & James on 2026-09-15';
    RAISE NOTICE '📅 1 pending booking request for vendor';
END $$;
