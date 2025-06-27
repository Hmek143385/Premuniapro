-- Function to generate client code
CREATE OR REPLACE FUNCTION generate_client_code()
RETURNS VARCHAR AS $$
DECLARE
    new_code VARCHAR;
    counter INTEGER := 1;
BEGIN
    LOOP
        new_code := 'CL' || LPAD(counter::TEXT, 6, '0');
        IF NOT EXISTS (SELECT 1 FROM contacts WHERE client_code = new_code) THEN
            RETURN new_code;
        END IF;
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to generate contract number
CREATE OR REPLACE FUNCTION generate_contract_number()
RETURNS VARCHAR AS $$
DECLARE
    new_number VARCHAR;
    counter INTEGER := 1;
BEGIN
    LOOP
        new_number := 'CT' || TO_CHAR(NOW(), 'YYYY') || LPAD(counter::TEXT, 6, '0');
        IF NOT EXISTS (SELECT 1 FROM contracts WHERE contract_number = new_number) THEN
            RETURN new_number;
        END IF;
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate client code
CREATE OR REPLACE FUNCTION set_client_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.client_code IS NULL OR NEW.client_code = '' THEN
        NEW.client_code := generate_client_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_client_code
    BEFORE INSERT ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION set_client_code();

-- Trigger to auto-generate contract number
CREATE OR REPLACE FUNCTION set_contract_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contract_number IS NULL OR NEW.contract_number = '' THEN
        NEW.contract_number := generate_contract_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_contract_number
    BEFORE INSERT ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION set_contract_number();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add update triggers
CREATE TRIGGER trigger_collaborators_updated_at
    BEFORE UPDATE ON collaborators
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_insurance_products_updated_at
    BEFORE UPDATE ON insurance_products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
