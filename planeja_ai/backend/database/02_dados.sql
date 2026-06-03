-- 02_dados.sql
-- Seed data for testing Planeja.AI database with 3 different profiles

-- Clear existing data (in order of dependencies)
TRUNCATE TABLE goals CASCADE;
TRUNCATE TABLE budgets CASCADE;
TRUNCATE TABLE transactions CASCADE;
TRUNCATE TABLE categories CASCADE;
TRUNCATE TABLE users CASCADE;

---------------------------------------------------------
-- 1. SEED USERS
---------------------------------------------------------
-- Profile 1: Guilherme (28yo, Medium/High Income, Organized)
-- Profile 2: Joana (32yo, Strict budget focus)
-- Profile 3: Lucas (21yo, Student, Simple needs)
INSERT INTO users (id, name, email, password_hash, age, notifications_push, notifications_email, notifications_sms, share_anonymous_data, theme_dark)
VALUES
('11111111-1111-1111-1111-111111111111', 'Guilherme', 'guilherme@gmail.com', '$2b$12$K3l8s7sD8F8gH9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c', 28, TRUE, TRUE, FALSE, FALSE, TRUE),
('22222222-2222-2222-2222-222222222222', 'Joana', 'joana@gmail.com', '$2b$12$R8s9t0u1v2w3x4y5z6a7b8cK3l8s7sD8F8gH9j0k1l2m3n4o5p6q', 32, TRUE, TRUE, TRUE, TRUE, FALSE),
('33333333-3333-3333-3333-333333333333', 'Lucas', 'lucas@gmail.com', '$2b$12$z6a7b8cK3l8s7sD8F8gH9j0k1l2m3n4o5p6qR8s9t0u1v2w3x4y5', 21, TRUE, FALSE, FALSE, FALSE, TRUE);


---------------------------------------------------------
-- 2. SEED CATEGORIES (User-specific)
---------------------------------------------------------
-- Guilherme's Categories
INSERT INTO categories (id, user_id, name, color_hex, icon_name) VALUES
('11111111-caca-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Alimentação Premium', '#FF5733', 'utensils'),
('11111111-caca-2222-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Transporte', '#3357FF', 'car'),
('11111111-caca-3333-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Lazer e Viagens', '#33FF57', 'palmtree'),
('11111111-caca-4444-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Aluguel e Contas', '#F3FF33', 'home'),
('11111111-caca-5555-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Investimentos', '#A633FF', 'trending-up');

-- Joana's Categories
INSERT INTO categories (id, user_id, name, color_hex, icon_name) VALUES
('22222222-caca-1111-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Alimentação Básica', '#FF8C00', 'shopping-cart'),
('22222222-caca-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Transporte Público', '#20B2AA', 'bus'),
('22222222-caca-3333-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Entretenimento Limite', '#FF1493', 'ticket'),
('22222222-caca-4444-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Contas do Lar', '#4682B4', 'home');

-- Lucas's Categories
INSERT INTO categories (id, user_id, name, color_hex, icon_name) VALUES
('33333333-caca-1111-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'Alimentação RU', '#CD5C5C', 'sandwich'),
('33333333-caca-2222-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'Livros e Faculdade', '#4B0082', 'book-open'),
('33333333-caca-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'Outros', '#708090', 'help-circle');


---------------------------------------------------------
-- 3. SEED BUDGETS
---------------------------------------------------------
-- Guilherme's Budgets (High limits)
INSERT INTO budgets (id, user_id, category_id, limit_value, month_year) VALUES
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', '11111111-caca-1111-1111-111111111111', 1200.00, '2026-06-01'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', '11111111-caca-2222-1111-111111111111', 600.00, '2026-06-01'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', '11111111-caca-3333-1111-111111111111', 1500.00, '2026-06-01'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', '11111111-caca-4444-1111-111111111111', 2500.00, '2026-06-01');

-- Joana's Budgets (Strict limits, one will be exceeded in transactions below)
INSERT INTO budgets (id, user_id, category_id, limit_value, month_year) VALUES
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', '22222222-caca-1111-2222-222222222222', 500.00, '2026-06-01'),
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', '22222222-caca-2222-2222-222222222222', 150.00, '2026-06-01'),
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', '22222222-caca-3333-2222-222222222222', 100.00, '2026-06-01'), -- Will exceed
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', '22222222-caca-4444-2222-222222222222', 800.00, '2026-06-01');

-- Lucas's Budgets (Low limits)
INSERT INTO budgets (id, user_id, category_id, limit_value, month_year) VALUES
(gen_random_uuid(), '33333333-3333-3333-3333-333333333333', '33333333-caca-1111-3333-333333333333', 300.00, '2026-06-01'),
(gen_random_uuid(), '33333333-3333-3333-3333-333333333333', '33333333-caca-2222-3333-333333333333', 100.00, '2026-06-01');


---------------------------------------------------------
-- 4. SEED TRANSACTIONS
---------------------------------------------------------
-- Guilherme's Transactions (High salary, high expenses, but healthy surplus)
INSERT INTO transactions (user_id, category_id, type, value, date, description) VALUES
('11111111-1111-1111-1111-111111111111', NULL, 'income', 8500.00, '2026-06-01', 'Salário Dev Senior'),
('11111111-1111-1111-1111-111111111111', '11111111-caca-4444-1111-111111111111', 'expense', 2200.00, '2026-06-02', 'Aluguel do Loft'),
('11111111-1111-1111-1111-111111111111', '11111111-caca-1111-1111-111111111111', 'expense', 180.00, '2026-06-02', 'Jantar Restaurante Italiano'),
('11111111-1111-1111-1111-111111111111', '11111111-caca-2222-1111-111111111111', 'expense', 80.00, '2026-06-03', 'Combustível Carro'),
('11111111-1111-1111-1111-111111111111', '11111111-caca-3333-1111-111111111111', 'expense', 350.00, '2026-06-03', 'Reserva de Hotel Fim de Semana'),
('11111111-1111-1111-1111-111111111111', '11111111-caca-5555-1111-111111111111', 'expense', 2000.00, '2026-06-03', 'Aporte CDB Liquidez Diária');

-- Joana's Transactions (Exceeds entertainment budget of 100.00 with a 120.00 show ticket)
INSERT INTO transactions (user_id, category_id, type, value, date, description) VALUES
('22222222-2222-2222-2222-222222222222', NULL, 'income', 3200.00, '2026-06-01', 'Salário CLT'),
('22222222-2222-2222-2222-222222222222', '22222222-caca-4444-2222-222222222222', 'expense', 750.00, '2026-06-01', 'Condomínio e Energia'),
('22222222-caca-1111-2222-222222222222', '22222222-caca-1111-2222-222222222222', 'expense', 150.00, '2026-06-02', 'Compras Supermercado'),
('22222222-2222-2222-2222-222222222222', '22222222-caca-2222-2222-222222222222', 'expense', 44.00, '2026-06-02', 'Recarga Bilhete Único'),
('22222222-2222-2222-2222-222222222222', '22222222-caca-3333-2222-222222222222', 'expense', 120.00, '2026-06-03', 'Ingresso Show'); -- Budget Exceeded!

-- Lucas's Transactions (Low income, low expenses, small budget remaining)
INSERT INTO transactions (user_id, category_id, type, value, date, description) VALUES
('33333333-3333-3333-3333-333333333333', NULL, 'income', 800.00, '2026-06-01', 'Bolsa Estágio'),
('33333333-3333-3333-3333-333333333333', NULL, 'income', 200.00, '2026-06-02', 'Ajuda de Custo Família'),
('33333333-3333-3333-3333-333333333333', '33333333-caca-1111-3333-333333333333', 'expense', 15.00, '2026-06-02', 'Almoço Restaurante Universitário'),
('33333333-3333-3333-3333-333333333333', '33333333-caca-2222-3333-333333333333', 'expense', 85.00, '2026-06-03', 'Livro Cálculo II');


---------------------------------------------------------
-- 5. SEED GOALS
---------------------------------------------------------
-- Guilherme's Goals (Buying a house, retiring)
INSERT INTO goals (user_id, category_id, name, target_value, current_value, deadline, status) VALUES
('11111111-1111-1111-1111-111111111111', '11111111-caca-4444-1111-111111111111', 'Entrada do Apartamento', 80000.00, 15000.00, '2028-12-31', 'in_progress'),
('11111111-1111-1111-1111-111111111111', '11111111-caca-5555-1111-111111111111', 'Reserva de Aposentadoria', 500000.00, 42000.00, '2045-01-01', 'in_progress');

-- Joana's Goals (Emergency fund - already fully completed)
INSERT INTO goals (user_id, category_id, name, target_value, current_value, deadline, status) VALUES
('22222222-2222-2222-2222-222222222222', '22222222-caca-4444-2222-222222222222', 'Reserva de Emergência', 10000.00, 10000.00, '2026-05-30', 'completed');

-- Lucas's Goals (New laptop for college - delayed since current_value is low vs target close to deadline)
INSERT INTO goals (user_id, category_id, name, target_value, current_value, deadline, status) VALUES
('33333333-3333-3333-3333-333333333333', '33333333-caca-3333-3333-333333333333', 'Notebook Novo', 3500.00, 200.00, '2026-07-15', 'delayed');
