a = float(input("Введите первое число: "))
b = float(input("Введите второе число: "))
operatsiya = input("Введите операцию (+, -, *, /): ")

if operatsiya == "+":
    rezultat = a + b
    print(f"{a} + {b} = {rezultat}")
elif operatsiya == "-":
    rezultat = a - b
    print(f"{a} - {b} = {rezultat}")
elif operatsiya == "*":
    rezultat = a * b
    print(f"{a} * {b} = {rezultat}")
elif operatsiya == "/":
    if b == 0:
        print("На ноль делить нельзя.")
    else:
        rezultat = a / b
        print(f"{a} / {b} = {rezultat}")
else:
    print("Неизвестная операция. Используйте +, -, * или /.")
