-- Wedding Planner Database Initialization Script
-- This script runs automatically when PostgreSQL container starts for the first time

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS & AUTHENTICATION
-- =====================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('couple', 'vendor', 'guest')),
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE support_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    chatwoot_agent_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CATEGORIES (Admin Managed)
-- =====================================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    name_fr VARCHAR(100),
    name_es VARCHAR(100),
    icon VARCHAR(50),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT INTO categories (name, name_ar, name_fr, name_es, icon, display_order) VALUES
('Photography', 'التصوير', 'Photographie', 'Fotografía', 'camera_alt', 1),
('Videography', 'التصوير المرئي', 'Vidéographie', 'Videografía', 'videocam', 2),
('Catering', 'الضيافة', 'Traiteur', 'Catering', 'restaurant', 3),
('Cake & Desserts', 'الكيك والحلويات', 'Gâteau et Desserts', 'Pastel y Postres', 'cake', 4),
('Music & DJ', 'الموسيقى والدي جي', 'Musique et DJ', 'Música y DJ', 'music_note', 5),
('Flowers & Florist', 'الزهور', 'Fleurs', 'Flores', 'local_florist', 6),
('Decor & Design', 'الديكور والتصميم', 'Décoration', 'Decoración', 'palette', 7),
('Venue', 'القاعة', 'Lieu', 'Lugar', 'location_on', 8),
('Wedding Planner', 'منظم الزفاف', 'Planificateur de Mariage', 'Planificador de Bodas', 'event_note', 9),
('Makeup & Hair', 'المكياج والشعر', 'Maquillage et Coiffure', 'Maquillaje y Peinado', 'face', 10),
('Wedding Dress', 'فستان الزفاف', 'Robe de Mariée', 'Vestido de Novia', 'checkroom', 11),
('Transportation', 'النقل', 'Transport', 'Transporte', 'directions_car', 12),
('Invitations', 'الدعوات', 'Invitations', 'Invitaciones', 'mail', 13),
('Jewelry', 'المجوهرات', 'Bijoux', 'Joyería', 'diamond', 14),
('Henna Artist', 'فنانة الحناء', 'Artiste Henné', 'Artista de Henna', 'brush', 15);

-- =====================================================
-- VENDORS
-- =====================================================

CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(200) NOT NULL,
    category_id UUID REFERENCES categories(id),
    description TEXT,

    -- Location
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- Business Info
    price_range VARCHAR(10) CHECK (price_range IN ('$', '$$', '$$$', '$$$$')),

    -- Ratings
    rating_avg DECIMAL(2, 1) DEFAULT 0,
    review_count INTEGER DEFAULT 0,

    -- Approval & Commission (FLEXIBLE PER VENDOR)
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')),
    commission_rate DECIMAL(4, 2) DEFAULT 10.00,
    contract_notes TEXT,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES admins(id),

    -- Verification
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    documents JSONB,

    -- Stats
    response_time_hours INTEGER,
    weddings_completed INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vendor_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    features JSONB,
    duration_hours INTEGER,
    is_popular BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vendor_portfolio (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(200),
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- WEDDINGS & COUPLES
-- =====================================================

CREATE TABLE weddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    partner1_name VARCHAR(100),
    partner2_name VARCHAR(100),
    wedding_date DATE,

    -- Budget
    budget_total DECIMAL(12, 2),
    budget_spent DECIMAL(12, 2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',

    -- Guest Info
    guest_count_expected INTEGER,

    -- Preferences
    style_preferences TEXT[],
    cultural_traditions TEXT[],
    region VARCHAR(50),

    -- Progress
    planning_progress INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- BOOKINGS
-- =====================================================

CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    package_id UUID REFERENCES vendor_packages(id),

    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'confirmed', 'completed', 'cancelled')),

    -- Dates
    booking_date DATE NOT NULL,

    -- Amounts
    total_amount DECIMAL(10, 2),
    deposit_amount DECIMAL(10, 2),
    deposit_paid BOOLEAN DEFAULT false,

    -- Commission (captured at booking time)
    commission_rate DECIMAL(4, 2),
    commission_amount DECIMAL(10, 2),
    vendor_payout DECIMAL(10, 2),

    -- Notes
    couple_notes TEXT,
    vendor_notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- GUESTS & RSVP
-- =====================================================

CREATE TABLE guests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    group_name VARCHAR(50),

    -- RSVP
    rsvp_status VARCHAR(20) DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'accepted', 'declined')),
    plus_one_allowed BOOLEAN DEFAULT false,
    plus_one_name VARCHAR(200),
    plus_one_attending BOOLEAN,

    -- Preferences
    meal_preference VARCHAR(50),
    dietary_restrictions TEXT,
    song_request VARCHAR(200),
    message_to_couple TEXT,

    -- Seating
    table_assignment VARCHAR(50),

    -- Tracking
    invitation_sent_at TIMESTAMP,
    responded_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- BUDGET
-- =====================================================

CREATE TABLE budget_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    estimated_amount DECIMAL(10, 2),
    actual_amount DECIMAL(10, 2),
    vendor_id UUID REFERENCES vendors(id),
    booking_id UUID REFERENCES bookings(id),
    is_paid BOOLEAN DEFAULT false,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TASKS
-- =====================================================

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date DATE,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    category VARCHAR(50),
    linked_vendor_id UUID REFERENCES vendors(id),
    linked_booking_id UUID REFERENCES bookings(id),
    months_before INTEGER,
    is_custom BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INVITATIONS
-- =====================================================

CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    template_id VARCHAR(50),
    design_config JSONB,
    rsvp_deadline DATE,
    sent_count INTEGER DEFAULT 0,
    opened_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CHAT (Metadata - actual messages in Firebase)
-- =====================================================

CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    firebase_chat_id VARCHAR(100) UNIQUE NOT NULL,
    last_message_at TIMESTAMP,
    last_message_preview VARCHAR(200),
    unread_count_couple INTEGER DEFAULT 0,
    unread_count_vendor INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- REVIEWS
-- =====================================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    vendor_response TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SUPPORT
-- =====================================================

CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    agent_id UUID REFERENCES support_agents(id),
    chatwoot_conversation_id INTEGER,
    subject VARCHAR(200),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'pending', 'resolved', 'escalated')),
    priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    escalated_to UUID REFERENCES admins(id),
    escalated_at TIMESTAMP,
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE support_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID REFERENCES support_tickets(id),
    agent_id UUID REFERENCES support_agents(id),
    action_type VARCHAR(50),
    action_details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- COMMISSION TRACKING
-- =====================================================

CREATE TABLE commission_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id),
    vendor_id UUID REFERENCES vendors(id),
    gross_amount DECIMAL(10, 2) NOT NULL,
    commission_rate DECIMAL(4, 2) NOT NULL,
    commission_amount DECIMAL(10, 2) NOT NULL,
    vendor_payout DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'refunded')),
    payout_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_vendors_category ON vendors(category_id);
CREATE INDEX idx_vendors_status ON vendors(status);
CREATE INDEX idx_vendors_location ON vendors(location_city, location_country);
CREATE INDEX idx_bookings_wedding ON bookings(wedding_id);
CREATE INDEX idx_bookings_vendor ON bookings(vendor_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_guests_wedding ON guests(wedding_id);
CREATE INDEX idx_guests_rsvp ON guests(rsvp_status);
CREATE INDEX idx_tasks_wedding ON tasks(wedding_id);
CREATE INDEX idx_tasks_due ON tasks(due_date);
CREATE INDEX idx_reviews_vendor ON reviews(vendor_id);

-- =====================================================
-- INSERT DEFAULT ADMIN (Change password in production!)
-- =====================================================

-- Password: Admin@123 (bcrypt hash)
INSERT INTO admins (email, password_hash, name, role) VALUES
('admin@weddingplanner.app', '$2b$10$X7VYKvEuS8hKHrWMQjGqXeZ1W4c9M7NpE2F3G4H5I6J7K8L9M0N1O', 'Super Admin', 'super_admin');

-- =====================================================
-- DONE
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Database initialized successfully!';
    RAISE NOTICE '📊 Tables created: users, admins, support_agents, categories, vendors, vendor_packages, vendor_portfolio, weddings, bookings, guests, budget_items, tasks, invitations, chat_conversations, reviews, support_tickets, support_actions, commission_transactions';
    RAISE NOTICE '📁 Default categories inserted: 15 categories';
    RAISE NOTICE '👤 Default admin created: admin@weddingplanner.app';
END $$;
