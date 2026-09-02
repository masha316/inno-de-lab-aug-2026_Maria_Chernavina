import random

zagadannoe = random.randint(1, 20)
attempts = 5
ugadal = False

print("Я загадал число от 1 до 20. У тебя 5 попыток.")

while attempts > 0:
    dogadka = int(input("Твой вариант: "))
    attempts -= 1

    if dogadka == zagadannoe:
        print("Верно! Ты угадал число.")
        ugadal = True
        break
    elif dogadka > zagadannoe:
        print("Слишком много!")
    else:
        print("Слишком мало!")

    print(f"Осталось попыток: {attempts}")

if not ugadal:
    print(f"Попытки закончились. Я загадал число {zagadannoe}.")
