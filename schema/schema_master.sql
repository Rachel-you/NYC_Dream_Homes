-- Agent Roles Table
CREATE TABLE agent_roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    access_level VARCHAR(20) NOT NULL,
    creation_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_access_level CHECK (access_level IN ('Read_Only', 'Data_Entry', 'Data_Manager', 'Admin')),
    CONSTRAINT chk_role_name CHECK (role_name IN ('Manager', 'Intern', 'Executive', 'Supervisor'))
);

-- Property Types Table
CREATE TABLE property_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Apartment', 'Townhouse', 'Condo', 'Villa', 'Studio'))
);

-- Property Status Table
CREATE TABLE property_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_status_name CHECK (status_name IN ('Pending', 'Reserved', 'Sold', 'Listed', 'Unavailable'))
);

-- Client Types Table
CREATE TABLE client_types (
    client_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    type_description VARCHAR(200) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Corporate', 'Individual', 'Non-Profit', 'Government', 'Small Business', 'VIP'))
);

-- Event Types Table
CREATE TABLE event_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Room Tour', 'Corporate Party', 'Networking Event', 'Open House'))
);

-- Transaction Types Table
CREATE TABLE transaction_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment', 'Refund', 'Charge'))
);

-- Addresses Table
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zipcode VARCHAR(15) NOT NULL
);

-- Employees Table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    address_id INT REFERENCES addresses(address_id),
    role_id INT REFERENCES agent_roles(role_id),
    office_id INT,
    employment_status VARCHAR(20) NOT NULL,
    sales_total NUMERIC(15, 2) DEFAULT 0.00,
    expense_budget NUMERIC(10, 2),
    CONSTRAINT chk_employment_status CHECK (employment_status IN ('Active', 'Inactive', 'On Leave', 'Terminated'))
);

-- Offices Table
CREATE TABLE offices (
    office_id SERIAL PRIMARY KEY,
    office_name VARCHAR(100) NOT NULL,
    address_id INT REFERENCES addresses(address_id),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    manager_id INT REFERENCES employees(employee_id),
    annual_budget NUMERIC(15, 2)
);

-- Properties Table
CREATE TABLE properties (
    property_id SERIAL PRIMARY KEY,
    address_id INT REFERENCES addresses(address_id),
    type_id INT REFERENCES property_types(type_id),
    price NUMERIC(10, 4) NOT NULL,
    status_id INT REFERENCES property_status(status_id),
    square_feet INT,
    number_of_bedrooms INT,
    number_of_bathrooms INT,
    year_built INT
);

-- Clients Table
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50),
    phone_number VARCHAR(20),
    address_id INT REFERENCES addresses(address_id),
    client_type_id INT REFERENCES client_types(client_type_id)
);

-- Events Table
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    type_id INT REFERENCES event_types(type_id),
    date DATE NOT NULL,
    property_id INT REFERENCES properties(property_id),
    agent_id INT REFERENCES employees(employee_id),
    participant_number INT,
    host VARCHAR(50),
    client_attendance TEXT,
    total_expense NUMERIC(10, 2) DEFAULT 0.00
);

-- Added Business Expenses Table
CREATE TABLE business_expenses (
    expense_id SERIAL PRIMARY KEY,
    office_id INT REFERENCES offices(office_id),
    event_id INT REFERENCES events(event_id),
    expense_date DATE NOT NULL,
    expense_type VARCHAR(50) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    description TEXT,
    approved_by INT REFERENCES employees(employee_id),
    status VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT chk_expense_type CHECK (expense_type IN ('Office Supplies', 'Utilities', 'Rent', 'Marketing', 'Travel', 'Maintenance', 'Technology', 'Training', 'Event', 'Miscellaneous')),
    CONSTRAINT chk_status CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Paid'))
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    client_id INT REFERENCES clients(client_id),
    agent_id INT REFERENCES employees(employee_id),
    date DATE NOT NULL,
    transaction_type_id INT REFERENCES transaction_types(type_id),
    price NUMERIC(10, 4),
    commission NUMERIC(10, 4),
    expense_id INT REFERENCES business_expenses(expense_id)
);

-- Maintenance Records Table
CREATE TABLE maintenance_records (
    maintenance_id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    description TEXT NOT NULL,
    cost NUMERIC(10, 4),
    responsible_person VARCHAR(30),
    status VARCHAR(20) CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled'))
);

-- Property Sales History Table
CREATE TABLE property_sales_history (
    sale_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    sale_date DATE NOT NULL,
    price NUMERIC(10, 4),
    buyer_id INT REFERENCES clients(client_id),
    seller_id INT REFERENCES clients(client_id),
    agent_id INT REFERENCES employees(employee_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    transaction_id INT REFERENCES transactions(transaction_id),
    payment_date DATE NOT NULL,
    amount NUMERIC(10, 4) NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('Credit Card', 'Bank Transfer', 'Cash', 'Check')),
    status VARCHAR(20) CHECK (status IN ('Pending', 'Completed', 'Failed'))
);

-- Indexes for Business Expenses
CREATE INDEX idx_expense_date ON business_expenses(expense_date);
CREATE INDEX idx_expense_type ON business_expenses(expense_type);
CREATE INDEX idx_event_expenses ON business_expenses(event_id);
