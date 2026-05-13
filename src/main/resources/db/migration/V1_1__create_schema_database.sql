-- Tabel Toko
CREATE TABLE stores
(
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    address    TEXT,
    phone      VARCHAR(20),
    is_active  BOOLEAN   DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT, -- ID user pembuat
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    deleted_at TIMESTAMP DEFAULT NULL,
    deleted_by BIGINT
);

-- Tabel Role
CREATE TABLE roles
(
    id         BIGSERIAL PRIMARY KEY,
    role_name  VARCHAR(50) NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);
CREATE UNIQUE INDEX idx_roles_name_active ON roles (role_name) WHERE deleted_at IS NULL;

-- Tabel Permission
CREATE TABLE permissions
(
    id              BIGSERIAL PRIMARY KEY,
    permission_name VARCHAR(100) UNIQUE NOT NULL
);

-- Tabel User
CREATE TABLE users
(
    id            BIGSERIAL PRIMARY KEY,
    store_id      BIGINT REFERENCES stores (id),
    role_id       BIGINT REFERENCES roles (id),
    username      VARCHAR(50) NOT NULL,
    password_hash TEXT        NOT NULL,
    full_name     VARCHAR(100),
    is_active     BOOLEAN   DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by    BIGINT REFERENCES users (id),
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by    BIGINT REFERENCES users (id),
    deleted_at    TIMESTAMP DEFAULT NULL,
    deleted_by    BIGINT REFERENCES users (id)
);
CREATE UNIQUE INDEX idx_users_username_active ON users (username) WHERE deleted_at IS NULL;

-- Individual Permission Override
CREATE TABLE user_permissions
(
    user_id       BIGINT REFERENCES users (id),
    permission_id BIGINT REFERENCES permissions (id),
    is_allowed    BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (user_id, permission_id)
);

-- Kategori
CREATE TABLE categories
(
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    created_by BIGINT REFERENCES users (id),
    updated_by BIGINT REFERENCES users (id),
    deleted_at TIMESTAMP DEFAULT NULL,
    deleted_by BIGINT REFERENCES users (id)
);

-- Satuan
CREATE TABLE units
(
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);
CREATE UNIQUE INDEX idx_units_name_active ON units (name) WHERE deleted_at IS NULL;

-- Produk
CREATE TABLE products
(
    id          BIGSERIAL PRIMARY KEY,
    category_id BIGINT REFERENCES categories (id),
    sku         VARCHAR(50)  NOT NULL,
    name        VARCHAR(150) NOT NULL,
    description TEXT,
    min_stock   DECIMAL(15, 2) DEFAULT 0,
    created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    created_by  BIGINT REFERENCES users (id),
    updated_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_by  BIGINT REFERENCES users (id),
    deleted_at  TIMESTAMP      DEFAULT NULL,
    deleted_by  BIGINT REFERENCES users (id)
);
CREATE UNIQUE INDEX idx_products_sku_active ON products (sku) WHERE deleted_at IS NULL;

-- Konversi Satuan per Produk
CREATE TABLE product_unit_conversions
(
    id           BIGSERIAL PRIMARY KEY,
    product_id   BIGINT REFERENCES products (id),
    unit_id      BIGINT REFERENCES units (id),
    base_unit_id BIGINT REFERENCES units (id),
    multiplier   DECIMAL(15, 2) NOT NULL,
    created_by   BIGINT REFERENCES users (id),
    deleted_at   TIMESTAMP DEFAULT NULL
);

-- Harga (Bisa diedit Admin per Toko)
CREATE TABLE product_prices
(
    id         BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products (id),
    store_id   BIGINT REFERENCES stores (id),
    unit_id    BIGINT REFERENCES units (id),
    price      DECIMAL(15, 2) NOT NULL,
    price_type VARCHAR(20) DEFAULT 'REGULAR',
    updated_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES users (id),
    deleted_at TIMESTAMP   DEFAULT NULL,
    deleted_by BIGINT REFERENCES users (id)
);

-- Master Gudang
CREATE TABLE warehouses
(
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    location   TEXT,
    deleted_at TIMESTAMP DEFAULT NULL,
    deleted_by BIGINT REFERENCES users (id)
);

-- Inventori
CREATE TABLE inventories
(
    id           BIGSERIAL PRIMARY KEY,
    product_id   BIGINT REFERENCES products (id),
    store_id     BIGINT REFERENCES stores (id),
    warehouse_id BIGINT REFERENCES warehouses (id),
    stock_qty    DECIMAL(15, 2) DEFAULT 0,
    updated_at   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_by   BIGINT REFERENCES users (id)
);

-- Penyesuaian Stok (Stock Opname)
CREATE TABLE stock_adjustments
(
    id             BIGSERIAL PRIMARY KEY,
    inventory_id   BIGINT REFERENCES inventories (id),
    store_id       BIGINT REFERENCES stores (id),
    user_id        BIGINT REFERENCES users (id),
    previous_qty   DECIMAL(15, 2) NOT NULL,
    actual_qty     DECIMAL(15, 2) NOT NULL,
    adjustment_qty DECIMAL(15, 2) NOT NULL,
    reason         TEXT           NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Penjualan
CREATE TABLE sales
(
    id             BIGSERIAL PRIMARY KEY,
    invoice_number VARCHAR(50)    NOT NULL,
    store_id       BIGINT REFERENCES stores (id),
    user_id        BIGINT REFERENCES users (id),
    customer_id    BIGINT,
    total_bruto    DECIMAL(15, 2) NOT NULL,
    total_netto    DECIMAL(15, 2) NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by     BIGINT REFERENCES users (id),
    deleted_at     TIMESTAMP DEFAULT NULL,
    deleted_by     BIGINT REFERENCES users (id)
);
CREATE UNIQUE INDEX idx_sales_invoice_active ON sales (invoice_number) WHERE deleted_at IS NULL;

-- Detail Penjualan
CREATE TABLE sale_details
(
    id            BIGSERIAL PRIMARY KEY,
    sale_id       BIGINT REFERENCES sales (id),
    product_id    BIGINT REFERENCES products (id),
    unit_id       BIGINT REFERENCES units (id),
    qty           DECIMAL(15, 2) NOT NULL,
    price_at_time DECIMAL(15, 2) NOT NULL,
    subtotal      DECIMAL(15, 2) NOT NULL
);

-- Pengeluaran
CREATE TABLE expenses
(
    id          BIGSERIAL PRIMARY KEY,
    store_id    BIGINT REFERENCES stores (id),
    amount      DECIMAL(15, 2) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by  BIGINT REFERENCES users (id),
    deleted_at  TIMESTAMP DEFAULT NULL,
    deleted_by  BIGINT REFERENCES users (id)
);

CREATE TABLE audit_logs
(
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT REFERENCES users (id),
    action     VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    table_name VARCHAR(50) NOT NULL,
    record_id  BIGINT      NOT NULL, -- Merujuk pada ID dari tabel yang diubah
    old_data   JSONB,
    new_data   JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);