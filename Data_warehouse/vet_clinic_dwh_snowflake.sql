-- =============================================================================
-- DWH Snowflake: Ветеринарная клиника
-- Физическая модель по образцу схемы «Снежинка» 
--
-- Бизнес-процесс: приём животного в клинике
--Цель анализа: оценка выручки (и загрузки) по приёмам.
-- Grain: 1 строка факта = 1 приём
-- =============================================================================

DROP SCHEMA IF EXISTS vet_dwh_snow CASCADE;
CREATE SCHEMA vet_dwh_snow;

CREATE TABLE vet_dwh_snow.dim_bio_type (
    bio_type_sk          SERIAL PRIMARY KEY,
    source_bio_type_id   SMALLINT NOT NULL,
    bio_type_name        VARCHAR(30) NOT NULL
);

CREATE TABLE vet_dwh_snow.dim_specialisation (
    specialisation_sk         SERIAL PRIMARY KEY,
    source_specialisation_id  SMALLINT NOT NULL,
    specialisation_name       VARCHAR(100) NOT NULL
);

-- -----------------------------------------------------------------------------
-- Основные измерения (dimensions)
-- -----------------------------------------------------------------------------

CREATE TABLE vet_dwh_snow.dim_date (
    date_sk         INT PRIMARY KEY,           -- YYYYMMDD
    source_date_id  DATE NOT NULL,
    year_num        INT NOT NULL,
    month_num       SMALLINT NOT NULL,
    month_name      VARCHAR(20) NOT NULL,
    day_num         SMALLINT NOT NULL,
    week_num        SMALLINT NOT NULL,
    day_name        VARCHAR(20) NOT NULL,
    is_weekend      BOOLEAN NOT NULL
);

CREATE TABLE vet_dwh_snow.dim_client (
    client_sk         SERIAL PRIMARY KEY,
    source_client_id  BIGINT NOT NULL,
    full_name         VARCHAR(201) NOT NULL,
    phone_number      VARCHAR(20),
    email             VARCHAR(254),
    birth_date        DATE
);

CREATE TABLE vet_dwh_snow.dim_pet (
    pet_sk          SERIAL PRIMARY KEY,
    source_pet_id   BIGINT NOT NULL,
    bio_type_sk     INT NOT NULL REFERENCES vet_dwh_snow.dim_bio_type(bio_type_sk),
    pet_name        VARCHAR(100) NOT NULL,
    sex             BOOLEAN,
    birth_date      DATE
);

CREATE TABLE vet_dwh_snow.dim_doctor (
    doctor_sk          SERIAL PRIMARY KEY,
    source_doctor_id   INT NOT NULL,
    specialisation_sk  INT NOT NULL REFERENCES vet_dwh_snow.dim_specialisation(specialisation_sk),
    full_name          VARCHAR(201) NOT NULL
);

-- dim_service: SCD Type 2 (версионирование цены)
-- При смене list_price старая строка закрывается (valid_to, is_current=false),
-- вставляется новая с новым service_sk. source_service_id не меняется.
CREATE TABLE vet_dwh_snow.dim_service (
    service_sk         SERIAL PRIMARY KEY,          -- новый на каждую версию
    source_service_id  SMALLINT NOT NULL,           -- бизнес-ключ из OLTP
    service_name       VARCHAR(100) NOT NULL,
    list_price         DECIMAL(8,2) NOT NULL,       -- атрибут, который версионируем
    valid_from         DATE NOT NULL,
    valid_to           DATE,                        -- NULL = версия ещё действует
    is_current         BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE vet_dwh_snow.dim_state (
    state_sk         SERIAL PRIMARY KEY,
    source_state_id  SMALLINT NOT NULL,
    state_name       VARCHAR(20) NOT NULL
);

-- -----------------------------------------------------------------------------
-- Таблица фактов 
-- -----------------------------------------------------------------------------

CREATE TABLE vet_dwh_snow.fact_appointments (
    appointment_sk         BIGSERIAL PRIMARY KEY,
    source_appointment_id  BIGINT NOT NULL,

    date_sk    INT NOT NULL REFERENCES vet_dwh_snow.dim_date(date_sk),
    client_sk  INT NOT NULL REFERENCES vet_dwh_snow.dim_client(client_sk),
    pet_sk     INT NOT NULL REFERENCES vet_dwh_snow.dim_pet(pet_sk),
    doctor_sk  INT NOT NULL REFERENCES vet_dwh_snow.dim_doctor(doctor_sk),
    service_sk INT NOT NULL REFERENCES vet_dwh_snow.dim_service(service_sk),
    state_sk   INT NOT NULL REFERENCES vet_dwh_snow.dim_state(state_sk),

    time_start TIMESTAMP NOT NULL,
    time_end   TIMESTAMP NOT NULL,

    -- метрики
    price              DECIMAL(8,2) NOT NULL,  -- зафиксированная цена приёма
    duration_minutes   INT NOT NULL,
    appointment_count  INT NOT NULL DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- Демо-данные
-- -----------------------------------------------------------------------------

INSERT INTO vet_dwh_snow.dim_bio_type (source_bio_type_id, bio_type_name) VALUES
(1, 'Крыса'),
(2, 'Кот'),
(3, 'Собака'),
(4, 'Хомяк');

INSERT INTO vet_dwh_snow.dim_specialisation (source_specialisation_id, specialisation_name) VALUES
(1, 'Терапия'),
(2, 'Хирургия'),
(3, 'Дерматология');

INSERT INTO vet_dwh_snow.dim_date VALUES
(20260301, '2026-03-01', 2026, 3, 'March', 1,  9, 'Sunday',    TRUE),
(20260302, '2026-03-02', 2026, 3, 'March', 2, 10, 'Monday',    FALSE),
(20260303, '2026-03-03', 2026, 3, 'March', 3, 10, 'Tuesday',   FALSE),
(20260304, '2026-03-04', 2026, 3, 'March', 4, 10, 'Wednesday', FALSE),
(20260305, '2026-03-05', 2026, 3, 'March', 5, 10, 'Thursday',  FALSE),
(20260310, '2026-03-10', 2026, 3, 'March', 10,11, 'Tuesday',   FALSE),
(20260315, '2026-03-15', 2026, 3, 'March', 15,11, 'Sunday',    TRUE),
(20260401, '2026-04-01', 2026, 4, 'April', 1, 14, 'Wednesday', FALSE),
(20260402, '2026-04-02', 2026, 4, 'April', 2, 14, 'Thursday',  FALSE),
(20260410, '2026-04-10', 2026, 4, 'April', 10,15, 'Friday',    FALSE);

INSERT INTO vet_dwh_snow.dim_client (source_client_id, full_name, phone_number, email, birth_date) VALUES
(1, 'Анна Иванова',    '+375291111111', 'anna@mail.test',   '1990-05-12'),
(2, 'Борис Петров',    '+375292222222', 'boris@mail.test',  '1985-11-03'),
(3, 'Вера Сидорова',   '+375293333333', 'vera@mail.test',   '1995-02-20'),
(4, 'Дмитрий Козлов',  '+375294444444', 'dmitry@mail.test', '1988-07-08');

INSERT INTO vet_dwh_snow.dim_pet (source_pet_id, bio_type_sk, pet_name, sex, birth_date)
SELECT v.source_pet_id, bt.bio_type_sk, v.pet_name, v.sex, v.birth_date
FROM (VALUES
    (1::bigint, 1::smallint, 'Мурка',  FALSE, '2020-01-15'::date),
    (2, 2, 'Барсик', TRUE,  '2019-06-01'),
    (3, 3, 'Рекс',   TRUE,  '2018-03-22'),
    (4, 4, 'Пушок',  TRUE,  '2024-09-10'),
    (5, 1, 'Луна',   FALSE, '2021-12-05'),
    (6, 3, 'Джек',   TRUE,  '2017-08-14')
) AS v(source_pet_id, source_bio_type_id, pet_name, sex, birth_date)
JOIN vet_dwh_snow.dim_bio_type bt ON bt.source_bio_type_id = v.source_bio_type_id;

INSERT INTO vet_dwh_snow.dim_doctor (source_doctor_id, specialisation_sk, full_name)
SELECT v.source_doctor_id, sp.specialisation_sk, v.full_name
FROM (VALUES
    (1, 1, 'Елена Смирнова'),
    (2, 2, 'Игорь Орлов'),
    (3, 3, 'Ольга Белова')
) AS v(source_doctor_id, source_specialisation_id, full_name)
JOIN vet_dwh_snow.dim_specialisation sp
  ON sp.source_specialisation_id = v.source_specialisation_id;

-- Начальные версии услуг (все текущие с 2026-01-01)
INSERT INTO vet_dwh_snow.dim_service
(source_service_id, service_name, list_price, valid_from, valid_to, is_current) VALUES
(1, 'Осмотр',        25.00, '2026-01-01', NULL, TRUE),
(2, 'Вакцинация',    40.00, '2026-01-01', NULL, TRUE),
(3, 'Операция',     250.00, '2026-01-01', NULL, TRUE),
(4, 'Чистка зубов',  80.00, '2026-01-01', NULL, TRUE),
(5, 'Анализы крови', 35.00, '2026-01-01', NULL, TRUE);

-- SCD Type 2: смена цены с 2026-04-01
-- 1) закрываем старую версию
-- 2) вставляем новую (новый service_sk, тот же source_service_id)

-- Чистка зубов: 80.00 → 90.00
UPDATE vet_dwh_snow.dim_service
SET valid_to = '2026-04-01',
    is_current = FALSE
WHERE source_service_id = 4
  AND is_current = TRUE;

INSERT INTO vet_dwh_snow.dim_service
(source_service_id, service_name, list_price, valid_from, valid_to, is_current)
VALUES (4, 'Чистка зубов', 90.00, '2026-04-01', NULL, TRUE);

-- Операция: 250.00 → 270.00
UPDATE vet_dwh_snow.dim_service
SET valid_to = '2026-04-01',
    is_current = FALSE
WHERE source_service_id = 3
  AND is_current = TRUE;

INSERT INTO vet_dwh_snow.dim_service
(source_service_id, service_name, list_price, valid_from, valid_to, is_current)
VALUES (3, 'Операция', 270.00, '2026-04-01', NULL, TRUE);

INSERT INTO vet_dwh_snow.dim_state (source_state_id, state_name) VALUES
(1, 'Planned'),
(2, 'Completed'),
(3, 'Cancelled');

-- Факт связывается с ВЕРСИЕЙ услуги на дату приёма (не просто is_current)
INSERT INTO vet_dwh_snow.fact_appointments
(source_appointment_id, date_sk, client_sk, pet_sk, doctor_sk, service_sk, state_sk,
 time_start, time_end, price, duration_minutes, appointment_count)
SELECT
    v.source_appointment_id,
    v.date_sk,
    c.client_sk,
    p.pet_sk,
    d.doctor_sk,
    s.service_sk,
    st.state_sk,
    v.time_start,
    v.time_end,
    v.price,
    v.duration_minutes,
    1
FROM (VALUES
    (101, 20260302, 1, 1, 1, 1, 2, '2026-03-02 10:00'::timestamp, '2026-03-02 10:30'::timestamp,  25.00,  30),
    (102, 20260302, 2, 3, 2, 3, 2, '2026-03-02 11:00', '2026-03-02 13:00', 250.00, 120),
    (103, 20260303, 1, 2, 1, 2, 2, '2026-03-03 09:00', '2026-03-03 09:20',  40.00,  20),
    (104, 20260303, 3, 4, 3, 1, 3, '2026-03-03 12:00', '2026-03-03 12:30',  25.00,  30),
    (105, 20260304, 4, 6, 1, 5, 2, '2026-03-04 15:00', '2026-03-04 15:40',  35.00,  40),
    (106, 20260305, 2, 3, 3, 4, 2, '2026-03-05 10:00', '2026-03-05 11:00',  80.00,  60),
    (107, 20260310, 3, 5, 1, 2, 2, '2026-03-10 14:00', '2026-03-10 14:25',  40.00,  25),
    (108, 20260315, 4, 6, 2, 1, 1, '2026-03-15 16:00', '2026-03-15 16:30',  25.00,  30),
    (109, 20260401, 1, 1, 3, 4, 2, '2026-04-01 11:00', '2026-04-01 12:00',  85.00,  60),
    (110, 20260402, 2, 3, 1, 1, 2, '2026-04-02 09:30', '2026-04-02 10:00',  25.00,  30),
    (111, 20260410, 3, 5, 2, 3, 2, '2026-04-10 13:00', '2026-04-10 15:30', 260.00, 150),
    (112, 20260410, 4, 6, 1, 5, 3, '2026-04-10 16:00', '2026-04-10 16:30',  35.00,  30)
) AS v(source_appointment_id, date_sk, source_client_id, source_pet_id, source_doctor_id,
       source_service_id, source_state_id, time_start, time_end, price, duration_minutes)
JOIN vet_dwh_snow.dim_client  c  ON c.source_client_id  = v.source_client_id
JOIN vet_dwh_snow.dim_pet     p  ON p.source_pet_id     = v.source_pet_id
JOIN vet_dwh_snow.dim_doctor  d  ON d.source_doctor_id  = v.source_doctor_id
JOIN vet_dwh_snow.dim_service s
  ON s.source_service_id = v.source_service_id
 AND v.time_start::date >= s.valid_from
 AND (s.valid_to IS NULL OR v.time_start::date < s.valid_to)
JOIN vet_dwh_snow.dim_state   st ON st.source_state_id  = v.source_state_id;

-- -----------------------------------------------------------------------------
-- Проверка структуры
-- -----------------------------------------------------------------------------
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'vet_dwh_snow'
ORDER BY table_name;

-- -----------------------------------------------------------------------------
-- Аналитические запросы (Snowflake)
-- -----------------------------------------------------------------------------

-- Q1. Выручка по месяцам (Completed) 
--Сколько клиника заработала по месяцам?
SELECT
    d.year_num,
    d.month_name,
    SUM(f.price) AS revenue,
    SUM(f.appointment_count) AS completed_appointments
FROM vet_dwh_snow.fact_appointments f
JOIN vet_dwh_snow.dim_date  d  ON d.date_sk  = f.date_sk
JOIN vet_dwh_snow.dim_state st ON st.state_sk = f.state_sk
WHERE st.state_name = 'Completed'
GROUP BY d.year_num, d.month_num, d.month_name
ORDER BY d.year_num, d.month_num;

-- Q2. Загрузка врачей (через dim_specialisation — ветка снежинки)
--Кто из врачей наиболее загружен и сколько принёс выручки?
SELECT
    doc.full_name AS doctor_name,
    sp.specialisation_name,
    SUM(f.appointment_count) AS appointments,
    SUM(f.duration_minutes) AS total_minutes,
    ROUND(SUM(f.price), 2) AS revenue
FROM vet_dwh_snow.fact_appointments f
JOIN vet_dwh_snow.dim_doctor         doc ON doc.doctor_sk         = f.doctor_sk
JOIN vet_dwh_snow.dim_specialisation sp  ON sp.specialisation_sk  = doc.specialisation_sk
JOIN vet_dwh_snow.dim_state          st  ON st.state_sk           = f.state_sk
WHERE st.state_name = 'Completed'
GROUP BY doc.doctor_sk, doc.full_name, sp.specialisation_name
ORDER BY appointments DESC;

-- Q3. Виды животных (через dim_bio_type — ветка снежинки)
-- Какие виды животных чаще всего принимаются в клинику?
SELECT
    bt.bio_type_name,
    SUM(f.appointment_count) AS appointments,
    ROUND(SUM(f.price), 2) AS revenue
FROM vet_dwh_snow.fact_appointments f
JOIN vet_dwh_snow.dim_pet      p  ON p.pet_sk       = f.pet_sk
JOIN vet_dwh_snow.dim_bio_type bt ON bt.bio_type_sk = p.bio_type_sk
JOIN vet_dwh_snow.dim_state    st ON st.state_sk    = f.state_sk
WHERE st.state_name <> 'Cancelled'
GROUP BY bt.bio_type_name
ORDER BY appointments DESC;

-- Q4. Доля статусов приёмов
--Какова доля отменённых приёмов?   
SELECT
    st.state_name,
    COUNT(*) AS cnt,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM vet_dwh_snow.fact_appointments f
JOIN vet_dwh_snow.dim_state st ON st.state_sk = f.state_sk
GROUP BY st.state_name
ORDER BY cnt DESC;

-- Q5. Средний чек по услугам (по версиям SCD2 — разный list_price)
SELECT
    srv.source_service_id,
    srv.service_name,
    srv.list_price,
    srv.valid_from,
    srv.valid_to,
    srv.is_current,
    ROUND(AVG(f.price), 2) AS avg_fact_price,
    COUNT(*) AS completed_cnt
FROM vet_dwh_snow.fact_appointments f
JOIN vet_dwh_snow.dim_service srv ON srv.service_sk = f.service_sk
JOIN vet_dwh_snow.dim_state   st  ON st.state_sk     = f.state_sk
WHERE st.state_name = 'Completed'
GROUP BY srv.service_sk, srv.source_service_id, srv.service_name,
         srv.list_price, srv.valid_from, srv.valid_to, srv.is_current
ORDER BY srv.source_service_id, srv.valid_from;

-- Q6. История цен услуг (все версии SCD Type 2)
--Как менялась цена услуг со временем?
SELECT
    service_sk,
    source_service_id,
    service_name,
    list_price,
    valid_from,
    valid_to,
    is_current
FROM vet_dwh_snow.dim_service
ORDER BY source_service_id, valid_from;

-- Q7. Приёмы + прайс версии услуги на дату (SCD2)
--По какому прайсу считался каждый приём — и совпадает ли он с фактической ценой?
SELECT
    f.source_appointment_id,
    f.time_start::date AS appointment_date,
    srv.service_name,
    srv.list_price AS price_in_dim_version,
    f.price AS price_in_fact,
    srv.valid_from,
    srv.valid_to,
    srv.is_current
FROM vet_dwh_snow.fact_appointments f
JOIN vet_dwh_snow.dim_service srv ON srv.service_sk = f.service_sk
ORDER BY f.time_start;

-- -- =============================================================================
