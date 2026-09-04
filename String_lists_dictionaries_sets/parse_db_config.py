# Конфигурационный словарь, полученный от сервиса инициализации
db_config = {
    "connection": {
        "host": "production-db.internal",
        "port": 5432,
        "user": "postgres"
    }
}

# Шаг 1. Достаём вложенный словарь connection.
# Дальше работаем с ним: читаем host и port через .get(), чтобы не поймать KeyError.
connection = db_config.get("connection", {})
host = connection.get("host")
port = connection.get("port")

# Шаг 2. Ключа ssl_settings в конфиге нет, как и вложенного ssl_mode.
# .get() с запасным значением: если ключа нет — берём пустой словарь {},
# затем из него так же безопасно читаем ssl_mode (дефолт: verify-full).
ssl_settings = db_config.get("ssl_settings", {})
ssl_mode = ssl_settings.get("ssl_mode", "verify-full")

# Шаг 3. Меняем пользователя во вложенном словаре на admin.
connection["user"] = "admin"

# Шаг 4. Добавляем новый параметр прямо в словарь connection.
connection["max_connections"] = 100

# Шаг 5. Печатаем режим SSL и пары ключ-значение через .items().
print(f"SSL Mode: {ssl_mode}")
print("Параметры соединения:")
for key, value in connection.items():
    print(f"* {key}: {value}")
