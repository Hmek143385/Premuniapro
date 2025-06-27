-- Create collaborators table
CREATE TABLE IF NOT EXISTS collaborators (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'commercial',
    commission_rate NUMERIC(5,4) DEFAULT 0.0000,
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create contacts table
CREATE TABLE IF NOT EXISTS contacts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    client_code VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    email VARCHAR(255),
    phone VARCHAR(20),
    postal_code VARCHAR(10),
    city VARCHAR(100),
    family_situation VARCHAR(50),
    profession VARCHAR(100),
    source VARCHAR(50),
    status VARCHAR(50) DEFAULT 'prospect',
    health_profile JSONB DEFAULT '{}',
    assigned_to UUID REFERENCES collaborators(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create insurance_products table
CREATE TABLE IF NOT EXISTS insurance_products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    base_price NUMERIC(10,2) NOT NULL,
    commission_rate NUMERIC(5,4) DEFAULT 0.0000,
    cross_sell_priority INTEGER DEFAULT 0,
    recommended_products UUID[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create contracts table
CREATE TABLE IF NOT EXISTS contracts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_number VARCHAR(100) UNIQUE NOT NULL,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    product_id UUID REFERENCES insurance_products(id) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    city VARCHAR(100),
    signature_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    monthly_premium NUMERIC(10,2) NOT NULL,
    annual_premium NUMERIC(10,2) NOT NULL,
    monthly_commission NUMERIC(10,2) DEFAULT 0,
    annual_commission NUMERIC(10,2) DEFAULT 0,
    first_year_commission NUMERIC(10,2) DEFAULT 0,
    recurring_commission NUMERIC(10,2) DEFAULT 0,
    received_commission NUMERIC(10,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    assigned_to UUID REFERENCES collaborators(id),
    country VARCHAR(100) DEFAULT 'France',
    charge NUMERIC(10,2) DEFAULT 0,
    expenses NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create interactions table
CREATE TABLE IF NOT EXISTS interactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    type VARCHAR(50) NOT NULL,
    outcome VARCHAR(100),
    scheduled_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER DEFAULT 0,
    notes TEXT,
    next_step VARCHAR(200),
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create sales_targets table
CREATE TABLE IF NOT EXISTS sales_targets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_value NUMERIC(12,2) NOT NULL,
    min_value NUMERIC(12,2) DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    weight INTEGER DEFAULT 100,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create workflows table
CREATE TABLE IF NOT EXISTS workflows (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    trigger_type VARCHAR(50) NOT NULL,
    trigger_config JSONB DEFAULT '{}',
    actions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES collaborators(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create workflow_logs table
CREATE TABLE IF NOT EXISTS workflow_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workflow_id UUID REFERENCES workflows(id) NOT NULL,
    contact_id UUID REFERENCES contacts(id),
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending',
    execution_details TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_contacts_assigned_to ON contacts(assigned_to);
CREATE INDEX IF NOT EXISTS idx_contracts_contact_id ON contracts(contact_id);
CREATE INDEX IF NOT EXISTS idx_contracts_assigned_to ON contracts(assigned_to);
CREATE INDEX IF NOT EXISTS idx_interactions_contact_id ON interactions(contact_id);
CREATE INDEX IF NOT EXISTS idx_interactions_collaborator_id ON interactions(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_sales_targets_collaborator_id ON sales_targets(collaborator_id);
