-- This SQL script was generated with Perplexity with the following prompt :
-- https://www.perplexity.ai/search/write-a-sql-script-for-postgre-6Xh87HYqTGS5p.YdCg0dWw
-- ```
-- Write a sql script for postgresql.
-- It should contain valid sql with 15 tables with some relationships and column constraints.
-- Tables and columns must be described with SQL "COMMENT ON" statements.
-- Business domain in insurance, it's about a policy admin system : from subscription through lifecycle management
-- ```

-- Create tables

-- Customers
CREATE TABLE customers
(
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)         NOT NULL,
    last_name     VARCHAR(50)         NOT NULL,
    date_of_birth DATE                NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone         VARCHAR(20),
    address       TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE customers IS 'Stores information about insurance policy holders';
COMMENT
ON COLUMN customers.customer_id IS 'Unique identifier for each customer';
COMMENT
ON COLUMN customers.email IS 'Customer''s email address, used for communication';

-- Products
CREATE TABLE products
(
    product_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    category    VARCHAR(50)  NOT NULL,
    is_active   BOOLEAN   DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE products IS 'Contains details about insurance products offered';
COMMENT
ON COLUMN products.category IS 'Category of the insurance product (e.g., life, health, property)';

-- Policies
CREATE TABLE policies
(
    policy_id      SERIAL PRIMARY KEY,
    customer_id    INTEGER REFERENCES customers (customer_id),
    product_id     INTEGER REFERENCES products (product_id),
    policy_number  VARCHAR(20) UNIQUE NOT NULL,
    start_date     DATE               NOT NULL,
    end_date       DATE               NOT NULL,
    premium_amount DECIMAL(10, 2)     NOT NULL,
    status         VARCHAR(20)        NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (end_date > start_date)
);

COMMENT
ON TABLE policies IS 'Stores information about individual insurance policies';
COMMENT
ON COLUMN policies.premium_amount IS 'The amount of premium to be paid for the policy';
COMMENT
ON COLUMN policies.status IS 'Current status of the policy (e.g., active, lapsed, cancelled)';

-- Claims
CREATE TABLE claims
(
    claim_id     SERIAL PRIMARY KEY,
    policy_id    INTEGER REFERENCES policies (policy_id),
    claim_number VARCHAR(20) UNIQUE NOT NULL,
    claim_date   DATE               NOT NULL,
    claim_amount DECIMAL(12, 2)     NOT NULL,
    status       VARCHAR(20)        NOT NULL,
    description  TEXT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE claims IS 'Records claims made against policies';
COMMENT
ON COLUMN claims.claim_amount IS 'The amount claimed by the policy holder';

-- Payments
CREATE TABLE payments
(
    payment_id     SERIAL PRIMARY KEY,
    policy_id      INTEGER REFERENCES policies (policy_id),
    amount         DECIMAL(10, 2) NOT NULL,
    payment_date   DATE           NOT NULL,
    payment_method VARCHAR(50)    NOT NULL,
    transaction_id VARCHAR(100) UNIQUE,
    status         VARCHAR(20)    NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE payments IS 'Tracks premium payments made by customers';
COMMENT
ON COLUMN payments.payment_method IS 'Method used for payment (e.g., credit card, bank transfer)';

-- Agents
CREATE TABLE agents
(
    agent_id         SERIAL PRIMARY KEY,
    first_name       VARCHAR(50)         NOT NULL,
    last_name        VARCHAR(50)         NOT NULL,
    email            VARCHAR(100) UNIQUE NOT NULL,
    phone            VARCHAR(20),
    commission_rate  DECIMAL(5, 2)       NOT NULL,
    hire_date        DATE                NOT NULL,
    termination_date DATE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_commission_rate CHECK (commission_rate >= 0 AND commission_rate <= 100)
);

COMMENT
ON TABLE agents IS 'Information about insurance agents';
COMMENT
ON COLUMN agents.commission_rate IS 'Commission rate for the agent (percentage)';

-- Policy_Agents
CREATE TABLE policy_agents
(
    policy_agent_id SERIAL PRIMARY KEY,
    policy_id       INTEGER REFERENCES policies (policy_id),
    agent_id        INTEGER REFERENCES agents (agent_id),
    assignment_date DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE policy_agents IS 'Links policies to their assigned agents';

-- Beneficiaries
CREATE TABLE beneficiaries
(
    beneficiary_id SERIAL PRIMARY KEY,
    policy_id      INTEGER REFERENCES policies (policy_id),
    first_name     VARCHAR(50)   NOT NULL,
    last_name      VARCHAR(50)   NOT NULL,
    relationship   VARCHAR(50)   NOT NULL,
    percentage     DECIMAL(5, 2) NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_percentage CHECK (percentage > 0 AND percentage <= 100)
);

COMMENT
ON TABLE beneficiaries IS 'Stores information about policy beneficiaries';
COMMENT
ON COLUMN beneficiaries.percentage IS 'Percentage of the benefit allocated to this beneficiary';

-- Risk_Assessments
CREATE TABLE risk_assessments
(
    assessment_id   SERIAL PRIMARY KEY,
    policy_id       INTEGER REFERENCES policies (policy_id),
    risk_score      INTEGER      NOT NULL,
    assessment_date DATE         NOT NULL,
    assessor_name   VARCHAR(100) NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_risk_score CHECK (risk_score >= 0 AND risk_score <= 100)
);

COMMENT
ON TABLE risk_assessments IS 'Records risk assessments for policies';
COMMENT
ON COLUMN risk_assessments.risk_score IS 'Calculated risk score (0-100)';

-- Documents
CREATE TABLE documents
(
    document_id   SERIAL PRIMARY KEY,
    policy_id     INTEGER REFERENCES policies (policy_id),
    document_type VARCHAR(50)  NOT NULL,
    file_name     VARCHAR(255) NOT NULL,
    upload_date   DATE         NOT NULL,
    file_size     INTEGER      NOT NULL,
    file_path     TEXT         NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE documents IS 'Stores documents related to policies';
COMMENT
ON COLUMN documents.document_type IS 'Type of document (e.g., policy contract, claim form)';

-- Endorsements
CREATE TABLE endorsements
(
    endorsement_id   SERIAL PRIMARY KEY,
    policy_id        INTEGER REFERENCES policies (policy_id),
    endorsement_type VARCHAR(50) NOT NULL,
    effective_date   DATE        NOT NULL,
    description      TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE endorsements IS 'Tracks changes or additions to existing policies';
COMMENT
ON COLUMN endorsements.endorsement_type IS 'Type of endorsement (e.g., coverage change, beneficiary update)';

-- Quotes
CREATE TABLE quotes
(
    quote_id       SERIAL PRIMARY KEY,
    customer_id    INTEGER REFERENCES customers (customer_id),
    product_id     INTEGER REFERENCES products (product_id),
    quote_date     DATE           NOT NULL,
    premium_amount DECIMAL(10, 2) NOT NULL,
    is_accepted    BOOLEAN,
    expiry_date    DATE           NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_quote_dates CHECK (expiry_date > quote_date)
);

COMMENT
ON TABLE quotes IS 'Stores quotes provided to potential customers';
COMMENT
ON COLUMN quotes.is_accepted IS 'Indicates whether the quote was accepted by the customer';

-- Renewals
CREATE TABLE renewals
(
    renewal_id   SERIAL PRIMARY KEY,
    policy_id    INTEGER REFERENCES policies (policy_id),
    renewal_date DATE           NOT NULL,
    new_premium  DECIMAL(10, 2) NOT NULL,
    is_accepted  BOOLEAN,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE renewals IS 'Tracks policy renewal information';
COMMENT
ON COLUMN renewals.new_premium IS 'New premium amount for the renewed policy';

-- Commissions
CREATE TABLE commissions
(
    commission_id     SERIAL PRIMARY KEY,
    agent_id          INTEGER REFERENCES agents (agent_id),
    policy_id         INTEGER REFERENCES policies (policy_id),
    commission_amount DECIMAL(10, 2) NOT NULL,
    payment_date      DATE           NOT NULL,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE commissions IS 'Records commissions paid to agents';
COMMENT
ON COLUMN commissions.commission_amount IS 'Amount of commission paid to the agent';

-- Customer_Communications
CREATE TABLE customer_communications
(
    communication_id   SERIAL PRIMARY KEY,
    customer_id        INTEGER REFERENCES customers (customer_id),
    communication_type VARCHAR(50)  NOT NULL,
    sent_date          TIMESTAMP    NOT NULL,
    subject            VARCHAR(255) NOT NULL,
    content            TEXT,
    is_read            BOOLEAN   DEFAULT FALSE,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT
ON TABLE customer_communications IS 'Logs communications sent to customers';
COMMENT
ON COLUMN customer_communications.communication_type IS 'Type of communication (e.g., email, SMS, letter)';
COMMENT
ON COLUMN customer_communications.is_read IS 'Indicates whether the communication has been read by the customer';


-- Insert sample data into customers
INSERT INTO customers (first_name, last_name, date_of_birth, email, phone, address) VALUES
('John', 'Doe', '1980-05-15', 'john.doe@email.com', '555-0101', '123 Main St, Anytown, USA'),
('Jane', 'Smith', '1992-08-22', 'jane.smith@email.com', '555-0102', '456 Oak Ave, Somewhere, USA'),
('Michael', 'Johnson', '1975-11-30', 'michael.j@email.com', '555-0103', '789 Pine Rd, Elsewhere, USA'),
('Emily', 'Brown', '1988-03-17', 'emily.brown@email.com', '555-0104', '321 Elm St, Nowhere, USA'),
('David', 'Wilson', '1995-09-05', 'david.wilson@email.com', '555-0105', '654 Birch Ln, Anyplace, USA');

-- Insert sample data into products
INSERT INTO products (name, description, category, is_active) VALUES
('Basic Life Insurance', 'Provides basic life coverage', 'Life', TRUE),
('Comprehensive Auto Insurance', 'Full coverage for your vehicle', 'Auto', TRUE),
('Home Insurance Plus', 'Protect your home and belongings', 'Property', TRUE),
('Travel Health Insurance', 'Health coverage for travelers', 'Health', TRUE),
('Business Liability Insurance', 'Protects against business liabilities', 'Business', TRUE);

-- Insert sample data into policies
INSERT INTO policies (customer_id, product_id, policy_number, start_date, end_date, premium_amount, status) VALUES
(1, 1, 'POL-001-2024', '2024-01-01', '2025-01-01', 1200.00, 'Active'),
(2, 2, 'POL-002-2024', '2024-02-15', '2025-02-15', 800.50, 'Active'),
(3, 3, 'POL-003-2024', '2024-03-10', '2025-03-10', 950.75, 'Active'),
(4, 4, 'POL-004-2024', '2024-04-05', '2025-04-05', 300.25, 'Active'),
(5, 5, 'POL-005-2024', '2024-05-20', '2025-05-20', 1500.00, 'Active');

-- Insert sample data into claims
INSERT INTO claims (policy_id, claim_number, claim_date, claim_amount, status, description) VALUES
(1, 'CLM-001-2024', '2024-06-15', 5000.00, 'Pending', 'Life insurance claim due to critical illness'),
(2, 'CLM-002-2024', '2024-07-22', 2500.00, 'Approved', 'Auto insurance claim for fender bender'),
(3, 'CLM-003-2024', '2024-08-30', 7500.00, 'Under Review', 'Home insurance claim for storm damage'),
(4, 'CLM-004-2024', '2024-09-05', 1000.00, 'Paid', 'Travel health insurance claim for emergency room visit'),
(5, 'CLM-005-2024', '2024-10-12', 10000.00, 'Pending', 'Business liability claim for customer injury');

-- Insert sample data into payments
INSERT INTO payments (policy_id, amount, payment_date, payment_method, transaction_id, status) VALUES
(1, 100.00, '2024-01-05', 'Credit Card', 'TRX-001-2024', 'Completed'),
(2, 66.70, '2024-02-20', 'Bank Transfer', 'TRX-002-2024', 'Completed'),
(3, 79.25, '2024-03-15', 'PayPal', 'TRX-003-2024', 'Completed'),
(4, 25.00, '2024-04-10', 'Debit Card', 'TRX-004-2024', 'Completed'),
(5, 125.00, '2024-05-25', 'Credit Card', 'TRX-005-2024', 'Completed');

-- Insert sample data into agents
INSERT INTO agents (first_name, last_name, email, phone, commission_rate, hire_date) VALUES
('Alice', 'Johnson', 'alice.j@insurance.com', '555-1001', 10.00, '2020-01-15'),
('Bob', 'Smith', 'bob.s@insurance.com', '555-1002', 12.50, '2019-05-22'),
('Carol', 'Williams', 'carol.w@insurance.com', '555-1003', 11.00, '2021-03-10'),
('Daniel', 'Brown', 'daniel.b@insurance.com', '555-1004', 9.50, '2022-07-01'),
('Eva', 'Davis', 'eva.d@insurance.com', '555-1005', 10.50, '2020-11-30');

-- Insert sample data into policy_agents
INSERT INTO policy_agents (policy_id, agent_id, assignment_date) VALUES
(1, 1, '2024-01-01'),
(2, 2, '2024-02-15'),
(3, 3, '2024-03-10'),
(4, 4, '2024-04-05'),
(5, 5, '2024-05-20');

-- Insert sample data into beneficiaries
INSERT INTO beneficiaries (policy_id, first_name, last_name, relationship, percentage) VALUES
(1, 'Sarah', 'Doe', 'Spouse', 100.00),
(2, 'Mark', 'Smith', 'Sibling', 50.00),
(2, 'Lisa', 'Smith', 'Sibling', 50.00),
(3, 'Oliver', 'Johnson', 'Child', 100.00),
(4, 'Emma', 'Brown', 'Parent', 100.00);

-- Insert sample data into risk_assessments
INSERT INTO risk_assessments (policy_id, risk_score, assessment_date, assessor_name, notes) VALUES
(1, 75, '2024-01-02', 'Dr. Risk Analyst', 'Higher risk due to pre-existing condition'),
(2, 45, '2024-02-16', 'Auto Risk Specialist', 'Average risk, clean driving record'),
(3, 60, '2024-03-11', 'Property Assessor', 'Moderate risk, older home in good condition'),
(4, 30, '2024-04-06', 'Travel Risk Expert', 'Low risk, short trip to low-risk country'),
(5, 80, '2024-05-21', 'Business Risk Consultant', 'High risk due to nature of business operations');

-- Insert sample data into documents
INSERT INTO documents (policy_id, document_type, file_name, upload_date, file_size, file_path) VALUES
(1, 'Policy Contract', 'life_policy_001.pdf', '2024-01-01', 1024, '/documents/life/001/'),
(2, 'Vehicle Registration', 'auto_reg_002.pdf', '2024-02-15', 512, '/documents/auto/002/'),
(3, 'Property Deed', 'home_deed_003.pdf', '2024-03-10', 768, '/documents/property/003/'),
(4, 'Passport Copy', 'passport_004.pdf', '2024-04-05', 256, '/documents/travel/004/'),
(5, 'Business License', 'business_license_005.pdf', '2024-05-20', 1280, '/documents/business/005/');

-- Insert sample data into endorsements
INSERT INTO endorsements (policy_id, endorsement_type, effective_date, description) VALUES
(1, 'Coverage Increase', '2024-03-01', 'Increased life insurance coverage by $100,000'),
(2, 'Add Driver', '2024-04-15', 'Added spouse as additional driver'),
(3, 'Add Valuable Item', '2024-05-10', 'Added coverage for new jewelry item'),
(4, 'Extend Coverage', '2024-06-05', 'Extended travel insurance for additional 2 weeks'),
(5, 'Modify Liability Limit', '2024-07-20', 'Increased liability coverage to $2 million');

-- Insert sample data into quotes
INSERT INTO quotes (customer_id, product_id, quote_date, premium_amount, is_accepted, expiry_date) VALUES
(1, 2, '2024-01-10', 850.00, TRUE, '2024-02-10'),
(2, 3, '2024-02-20', 1000.00, FALSE, '2024-03-20'),
(3, 4, '2024-03-15', 275.50, TRUE, '2024-04-15'),
(4, 5, '2024-04-25', 1600.00, NULL, '2024-05-25'),
(5, 1, '2024-05-05', 1100.00, TRUE, '2024-06-05');

-- Insert sample data into renewals
INSERT INTO renewals (policy_id, renewal_date, new_premium, is_accepted) VALUES
(1, '2024-12-01', 1250.00, TRUE),
(2, '2025-01-15', 825.00, NULL),
(3, '2025-02-10', 975.00, TRUE),
(4, '2025-03-05', 310.00, FALSE),
(5, '2025-04-20', 1550.00, NULL);

-- Insert sample data into commissions
INSERT INTO commissions (agent_id, policy_id, commission_amount, payment_date) VALUES
(1, 1, 120.00, '2024-02-01'),
(2, 2, 100.06, '2024-03-15'),
(3, 3, 104.58, '2024-04-10'),
(4, 4, 28.52, '2024-05-05'),
(5, 5, 157.50, '2024-06-20');

-- Insert sample data into customer_communications
INSERT INTO customer_communications (customer_id, communication_type, sent_date, subject, content, is_read) VALUES
(1, 'Email', '2024-01-05 10:00:00', 'Welcome to Your New Policy', 'Dear John, Welcome to your new life insurance policy...', TRUE),
(2, 'SMS', '2024-02-20 14:30:00', 'Payment Reminder', 'Your auto insurance payment is due in 5 days.', FALSE),
(3, 'Letter', '2024-03-12 09:00:00', 'Policy Renewal Notice', 'Dear Mr. Johnson, Your home insurance policy is up for renewal...', FALSE),
(4, 'Email', '2024-04-07 11:15:00', 'Claim Status Update', 'Dear Emily, We have an update on your recent travel insurance claim...', TRUE),
(5, 'Phone', '2024-05-22 16:45:00', 'Business Insurance Review', 'Called to schedule annual business insurance review.', TRUE);