# Отчёт

## Part 1: Выбор Сценария

Для данной работы выбран сценарий: **Система Управления Ветеринарной Клиникой**. Эта система будет управлять клиентами (хозяевами животных), питомцами, врачами, видами услуг и записями на приём.

## Part 2: Проектирование Базы Данных и Документация

### Идентификация Сущностей и Атрибутов

1. **Биологические виды** (`bio_types`): справочник видов животных (кошка, собака, хомяк и т.д.).
2. **Клиенты** (`clients`): хозяева животных. В качестве дополнительной полезности дата рождения хозяина может использоваться для рассылки с поздравлением клиента с днём рождения. Рассылка может отправляться через SMS на номер телефона или через электронную почту на указанный емейл.
3. **Питомцы** (`pets`): животные, привязанные к владельцу и к биологическому виду; дополнительно хранится пол животного (может быть неизвестен при первом обращении).
4. **Врачи** (`doctors`): сотрудники клиники, ведущие приём.
5. **Услуги** (`services`): виды услуг (осмотр, вакцинация, обследование, операция и т.п.) и их стоимость.
6. **Статусы записей** (`appointment_states`): справочник состояний записи на приём (запланирована, завершена, отменена и т.п.).
7. **Записи на приём** (`appointments`): факты записи питомца к врачу на конкретную услугу с указанием интервала времени, статуса и цены на момент записи.

### Проектирование Таблиц

#### 1. Table Name: bio_types

- **Description:** Хранит биологические виды животных (кошка, собака, хомяк и т.д.).
- **Attributes:**
  - `bio_type_id`: SMALLINT, PK, NOT NULL
  - `bio_type_name`: VARCHAR(30), NOT NULL
- **Constraints:**
  - `PK_bio_types`: PRIMARY KEY (`bio_type_id`)
  - `UQ_bio_type_name`: UNIQUE (`bio_type_name`)

#### 2. Table Name: clients

- **Description:** Хранит данные о клиентах — хозяевах животных. Поле `birth_date` в качестве дополнительной полезности может использоваться для рассылки с поздравлением клиента с днём рождения (SMS на `phone_number` или электронная почта на `email`) и поэтому допускает NULL (если дата рождения неизвестна).
- **Attributes:**
  - `client_id`: BIGINT, PK, NOT NULL
  - `first_name`: VARCHAR(100), NOT NULL
  - `last_name`: VARCHAR(100), NOT NULL
  - `phone_number`: VARCHAR(20), NOT NULL
  - `birth_date`: DATE, NULL
  - `email`: VARCHAR(254), NOT NULL
- **Constraints:**
  - `PK_clients`: PRIMARY KEY (`client_id`)
  - `UQ_phone_number`: UNIQUE (`phone_number`)
  - `UQ_email`: UNIQUE (`email`)
  - `CHK_client_birth_date`: CHECK (`birth_date IS NULL OR birth_date <= CURRENT_DATE`)

#### 3. Table Name: pets

- **Description:** Хранит информацию о питомцах: кличка, вид, дата рождения, пол и владелец. Пол может быть неизвестен при первом обращении, поэтому `sex` допускает NULL.
- **Attributes:**
  - `pet_id`: BIGINT, PK, NOT NULL
  - `name`: VARCHAR(100), NOT NULL
  - `bio_type_id`: SMALLINT, FK, NOT NULL
  - `birth_date`: DATE, NOT NULL
  - `client_id`: BIGINT, FK, NOT NULL
  - `sex`: BOOLEAN, NULL
- **Constraints:**
  - `PK_pets`: PRIMARY KEY (`pet_id`)
  - `FK_pets_bio_types`: FOREIGN KEY (`bio_type_id`) REFERENCES `bio_types(bio_type_id)`
  - `FK_pets_clients`: FOREIGN KEY (`client_id`) REFERENCES `clients(client_id)`
  - `CHK_pet_birth_date`: CHECK (`birth_date <= CURRENT_DATE`)

#### 4. Table Name: doctors

- **Description:** Хранит информацию о врачах ветеринарной клиники.
- **Attributes:**
  - `doctor_id`: INT, PK, NOT NULL
  - `first_name`: VARCHAR(100), NOT NULL
  - `last_name`: VARCHAR(100), NOT NULL
  - `specialisation`: VARCHAR(100), NOT NULL
- **Constraints:**
  - `PK_doctors`: PRIMARY KEY (`doctor_id`)

#### 5. Table Name: services

- **Description:** Хранит виды услуг клиники (осмотр, вакцинация, обследование, операция и т.п.) и стоимость каждой услуги.
- **Attributes:**
  - `service_id`: SMALLINT, PK, NOT NULL
  - `service_name`: VARCHAR(100), NOT NULL
  - `price`: DECIMAL(8,2), NOT NULL
- **Constraints:**
  - `PK_services`: PRIMARY KEY (`service_id`)
  - `UQ_service_name`: UNIQUE (`service_name`)
  - `CHK_price`: CHECK (`price >= 0`)

#### 6. Table Name: appointment_states

- **Description:** Справочник статусов записи на приём (запланирована, завершена, отменена и т.п.).
- **Attributes:**
  - `state_id`: SMALLINT, PK, NOT NULL
  - `state_name`: VARCHAR(20), NOT NULL
- **Constraints:**
  - `PK_appointment_states`: PRIMARY KEY (`state_id`)
  - `UQ_state_name`: UNIQUE (`state_name`)

#### 7. Table Name: appointments

- **Description:** Хранит записи на приём: связывает питомца, врача, услугу и статус; фиксирует дату и время начала и окончания приёма, необязательное текстовое описание и стоимость услуги на момент записи. Цена в `appointments.price` фиксируется при создании записи и не меняется при последующем изменении прайса в `services`.
- **Attributes:**
  - `appointment_id`: BIGINT, PK, NOT NULL
  - `time_start`: TIMESTAMP, NOT NULL
  - `time_end`: TIMESTAMP, NOT NULL
  - `state_id`: SMALLINT, FK, NOT NULL
  - `pet_id`: BIGINT, FK, NOT NULL
  - `doctor_id`: INT, FK, NOT NULL
  - `service_id`: SMALLINT, FK, NOT NULL
  - `description`: TEXT, NULL
  - `price`: DECIMAL(8,2), NOT NULL
- **Constraints:**
  - `PK_appointments`: PRIMARY KEY (`appointment_id`)
  - `FK_appointments_states`: FOREIGN KEY (`state_id`) REFERENCES `appointment_states(state_id)`
  - `FK_appointments_pets`: FOREIGN KEY (`pet_id`) REFERENCES `pets(pet_id)`
  - `FK_appointments_doctors`: FOREIGN KEY (`doctor_id`) REFERENCES `doctors(doctor_id)`
  - `FK_appointments_services`: FOREIGN KEY (`service_id`) REFERENCES `services(service_id)`
  - `CHK_appointment_times`: CHECK (`time_end > time_start`)
  - `CHK_appointment_price`: CHECK (`price >= 0`)

### Взаимосвязи:

**bio_types и pets (Один-ко-Многим):**

- Один биологический вид может соответствовать многим питомцам. Один питомец относится ровно к одному виду.
  - `pets.bio_type_id` является внешним ключом, ссылающимся на `bio_types.bio_type_id`.

**clients и pets (Один-ко-Многим):**

- Один клиент может быть хозяином многих животных. Один питомец принадлежит одному клиенту.
  - `pets.client_id` является внешним ключом, ссылающимся на `clients.client_id`.

**pets и appointments (Один-ко-Многим):**

- Один питомец может иметь много записей на приём. Одна запись относится к одному питомцу.
  - `appointments.pet_id` является внешним ключом, ссылающимся на `pets.pet_id`.

**doctors и appointments (Один-ко-Многим):**

- Один врач может вести много приёмов. Одна запись на приём назначается одному врачу.
  - `appointments.doctor_id` является внешним ключом, ссылающимся на `doctors.doctor_id`.

**services и appointments (Один-ко-Многим):**

- Один вид услуги может встречаться во многих записях на приём. Одна запись связана с одной услугой.
  - `appointments.service_id` является внешним ключом, ссылающимся на `services.service_id`.

**appointment_states и appointments (Один-ко-Многим):**

- Один статус может относиться ко многим записям. Одна запись имеет ровно один статус.
  - `appointments.state_id` является внешним ключом, ссылающимся на `appointment_states.state_id`.

**doctors и pets (Многие-ко-Многим):**

- Один врач может принимать многих питомцев, а один питомец может записываться ко многим врачам. Связь реализуется через промежуточную таблицу appointments.
- Связующая таблица `appointments` содержит внешние ключи `doctor_id` и `pet_id`.

**doctors и services (Многие-ко-Многим):**

- Один врач может оказывать многие услуги, а одна услуга может выполняться многими врачами. Связь реализуется через промежуточную таблицу appointments.
- Связующая таблица `appointments` содержит внешние ключи `doctor_id` и `service_id`.

## Part 3: ER-диаграмма

Ниже приведена ER-диаграмма выбранного сценария — системы управления ветеринарной клиникой. На диаграмме заданы сущности, типы столбцов, первичные и внешние ключи, а также связи «один-ко-многим».

![ER-диаграмма базы данных «Ветеринарная клиника»](er-diagram.png)

*Рисунок 1. ER-диаграмма базы данных «Ветеринарная клиника» (DrawSQL)*

### Пояснения к диаграмме

- **Ключи. **Для каждой сущности задан первичный ключ (`bio_type_id`, `client_id`, `pet_id`, `doctor_id`, `service_id`, `state_id`, `appointment_id`). Связи реализованы внешними ключами: `pets.bio_type_id`, `pets.client_id`, `appointments.state_id`, `appointments.pet_id`, `appointments.doctor_id`, `appointments.service_id`.
- **Именование. **Пробелы в именах таблиц и столбцов не используются. Применяется стиль `snake_case` (`phone_number`, `birth_date`, `last_name`, `time_start`, `time_end`, `appointment_id`), допустимый в целевой СУБД.
- **Типы данных. **Для каждого столбца задан тип: идентификаторы операционных сущностей — `BIGINT`/`INT`, справочники — `SMALLINT`, строки — `VARCHAR` с ограничением длины (телефон — `VARCHAR(20)`, email — `VARCHAR(254)`), стоимость в прайсе и снимок цены на момент записи — `DECIMAL(8,2)`, дата и время начала и окончания приёма — `TIMESTAMP`, пол питомца — `BOOLEAN` (допускает NULL), произвольный комментарий к записи — `TEXT`. Цена в `appointments.price` сохраняется отдельно от `services.price`, чтобы история визитов не менялась при обновлении прайса.
- **Связи. **Все связи на диаграмме — «один-ко-многим». Таблица `appointments` является центральной: она соединяет питомца, врача, услугу и статус. Таблица `pets` соединяет клиента и биологический вид.
- **Индексы. **На диаграмме для `clients.phone_number`, `clients.email` и `appointment_states.state_name` отмечены индексы; в документации они зафиксированы как уникальные ограничения.
