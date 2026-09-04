# Список ролей, переданный в запросе на авторизацию (содержит повторы)
requested_roles = ["guest", "developer", "guest", "admin",
                   "developer", "guest"]

# Набор обязательных ролей для выполнения административных функций
required_admin_roles = {"admin", "security_officer",
                        "audit_manager"}

# Шаг 1. Превращаем список в множество: set() сам убирает дубликаты.
# Циклы for/while для очистки не используем.
unique_requested = set(requested_roles)

# Шаг 2. Пересечение множеств (&): роли, которые есть и в запросе, и среди админских.
common_admin_roles = unique_requested & required_admin_roles

# Шаг 3. Разность множеств (-): обязательные админские роли, которых в запросе нет.
missing_admin_roles = required_admin_roles - unique_requested

# Шаг 4. Проверка членства через in по множеству — поиск за O(1).
has_security_officer = "security_officer" in unique_requested

print(f"Уникальные запрошенные роли: {unique_requested}")
print(f"Общие административные роли: {common_admin_roles}")
print(f"Недостающие административные роли: {missing_admin_roles}")
print(f"Наличие роли security_officer в запросе: {has_security_officer}")
