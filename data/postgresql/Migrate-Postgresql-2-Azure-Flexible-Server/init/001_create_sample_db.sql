
-- 001_create_sample_db.sql

-- Create the application role (errors on re-run if it already exists)
CREATE ROLE ${DEMO_USER} LOGIN PASSWORD '${DEMO_USER_PASSWORD}';

-- Create the database owned by that role
CREATE DATABASE ${DEMO_DB} OWNER ${DEMO_USER};

-- Connect to the new database (psql meta-command)
\connect ${DEMO_DB}

-- Create schema (owned by ${DEMO_USER})
CREATE SCHEMA app AUTHORIZATION ${DEMO_USER};

-- Create tables
CREATE TABLE app.customers (
  customer_id SERIAL PRIMARY KEY,
  first_name  VARCHAR(50)  NOT NULL,
  last_name   VARCHAR(50)  NOT NULL,
  email       VARCHAR(120) UNIQUE NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE app.orders (
  order_id     SERIAL PRIMARY KEY,
  customer_id  INT NOT NULL REFERENCES app.customers(customer_id),
  order_date   DATE NOT NULL DEFAULT CURRENT_DATE,
  status       VARCHAR(32) NOT NULL DEFAULT 'NEW',
  total_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00
);

-- Seed data (ON CONFLICT is fine; it won't raise an error if emails already exist)
INSERT INTO app.customers (first_name, last_name, email) VALUES
('Marie','Jeanne','marie.jeanne@example.com'),
('Alex','Durand','alex.durand@example.com'),
('Nadia','Pierre','nadia.pierre@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO app.orders (customer_id, order_date, status, total_amount) VALUES
(1, CURRENT_DATE - INTERVAL '2 day', 'PAID', 129.99),
(2, CURRENT_DATE - INTERVAL '1 day', 'NEW',  59.50),
(3, CURRENT_DATE,                    'NEW',  245.00);

-- Helpful indexes
CREATE INDEX idx_orders_customer_id ON app.orders(customer_id);
CREATE INDEX idx_orders_status      ON app.orders(status);

-- Grants
GRANT USAGE ON SCHEMA app TO ${DEMO_USER};
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO ${DEMO_USER};

-- Ensure future tables in schema app grant DML privileges to ${DEMO_USER}
ALTER DEFAULT PRIVILEGES IN SCHEMA app
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${DEMO_USER};
