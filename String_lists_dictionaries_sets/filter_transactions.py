# Список транзакций, полученных от платежного шлюза
raw_transactions = ["SUCCESS:100", "FAILED:50", "SUCCESS:-10",
                    "SUCCESS:0", "SUCCESS:250", "ERROR:200"]

# 
#   tx.startswith("SUCCESS") — оставляем только успешные платежи
#   (FAILED и ERROR отсеиваются);
#   int(tx.split(":")[1]) > 0 — сумма после двоеточия должна быть
#   строго положительной (0 и отрицательные значения — аномалии).
#
# Действие слева:
#   int(tx.split(":")[1]) — извлекаем сумму транзакции и приводим её к целому числу.
cleaned_transactions = [
    int(tx.split(":")[1])
    for tx in raw_transactions
    if tx.startswith("SUCCESS") and int(tx.split(":")[1]) > 0
]

print(f"Очищенные транзакции: {cleaned_transactions}")
