def process_transaction(user_id, amount, db_connection):
    log_entry = "Start processing"
    
    if amount > 0:
        status = "approved"
        balance = get_balance(user_id)
        new_balance = balance - amount
        update_balance(user_id, new_balance)
    
    log_entry = "Transaction finished with status: " + status
    
    file = open("audit_log.txt", "w")
    file.write(log_entry)
    
    return status


Переменная: user_id
	Def: Строка 1 (параметр функции process_transaction(user_id, amount, db_connection))
	Use: Строка 6 (передача в функцию get_balance(user_id))
	Use: Строка 8 (передача в функцию update_balance(user_id, new_balance))
Переменная: amount
	Def: Строка 1 (параметр функции process_transaction(user_id, amount, db_connection))
	Use: Строка 4 (проверка условия if amount > 0)
	Use: Строка 7 (вычисление нового баланса balance - amount)
Переменная: db_connection
	Def: Строка 1 (параметр функции process_transaction(user_id, amount, db_connection))
	Use: Нет (не используется в теле функции)
Переменная: log_entry
	Def: Строка 2 (первичное присваивание log_entry = "Start processing")
	Def: Строка 11 (перезапись значения log_entry = "Transaction finished with status: " + status)
	Use: Строка 14 (запись в файл file.write(log_entry))
Переменная: status
	Def: Строка 5 (присваивание значения status = "approved")
	Use: Строка 11 (конкатенация со строкой лога)
	Use: Строка 16 (возврат из функции return status)
Переменная: balance
	Def: Строка 6 (присваивание результата функции balance = get_balance(user_id))
	Use: Строка 7 (вычисление значения balance - amount)
Переменная: new_balance
	Def: Строка 7 (присваивание результата вычитания new_balance = balance - amount)
	Use: Строка 8 (передача в функцию update_balance(user_id, new_balance))
Переменная: file
	Def: Строка 13 (присваивание объекта файла file = open("audit_log.txt", "w"))
	Use: Строка 14 (вызов метода записи file.write(log_entry))

1. Использование неинициализированной переменной (Uninitialized Variable)
Где находится: Строка 10 (log_entry = "Transaction finished with status: " + status) и строка 15 (return status).
При каком условии возникнет ошибка: Ошибка NameError: free variable 'status' referenced before assignment in enclosing scope (или UnboundLocalError) произойдет, если amount <= 0.

2. Мертвое присваивание (Dead Store)
Где находится: Строка 2 (log_entry = "Start processing").
В чем суть: Переменной log_entry присваивается строковое значение, которое ни разу не считывается до того, как на ст

3. Утечка ресурса (Resource Leak)
Где находится: Строки 12–13 (file = open("audit_log.txt", "w")).
В чем суть: Функция открывает дескриптор файла для записи лога, но нигде не вызывает метод file.close().
