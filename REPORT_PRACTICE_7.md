# 1. Анализ потоков данных (DFA)
## 1.1. Таблица Def-Use цепочек для переменных log_entry, status, balance, new_balance, file.
Переменная: user_id Def: строка 1 (объявление в качестве параметра функции) Use: строка 5 (передача аргументом в get_balance), строка 7 (передача аргументом в update_balance)

Переменная: amount Def: строка 1 (объявление в качестве параметра функции) Use: строка 3 (проверка условия amount > 0), строка 6 (вычитание из баланса)

Переменная: db_connection Def: строка 1 (объявление в качестве параметра функции) Use: нет точек использования (переменная не используется в теле функции)

Переменная: log_entry Def: строка 2 (log_entry = "Start processing"), строка 8 (log_entry = "Transaction finished...") Use: строка 10 (запись значения переменной в файл через file.write)

Переменная: status Def: строка 4 (status = "approved") Use: строка 8 (использование в конкатенации строки), строка 11 (возврат из функции через return)

Переменная: balance Def: строка 5 (balance = get_balance(user_id)) Use: строка 6 (использование в арифметическом выражении balance - amount)

Переменная: new_balance Def: строка 6 (new_balance = balance - amount) Use: строка 7 (передача аргументом в update_balance)

Переменная: file Def: строка 9 (file = open(...)) Use: строка 10 (вызов метода .write())
## 1.2. Описание выявленных дефектов:
- Дефект 1 (Неинициализированная переменная): [Строка 1 (параметр status отсутствует для ветки else). Если amount <= 0, весь блок if пропускается. Функция неявно возвращает None, а транзакция завершается без присвоения какого-либо статуса.]
- Дефект 2 (Мертвое присваивание): [Строка 2 (log_entry = "Start processing"). Это значение никогда не читается. В строке 8 оно гарантированно перезаписывается, а при ложном if — просто исчезает при выходе из функции.]
- Дефект 3 (Утечка ресурса): [Строка 9 (file = open(...)). Файловый дескриптор открывается, но нигде не закрывается (file.close() отсутствует). После return status в строке 11 ресурс остается заблокированным в системе.]

# 2. Дизассемблирование
## 2.1. Восстановленный код на языке Python/C: [
def process_transaction(user_id, amount, db_connection):
    status = "pending"
    
  if amount > 0:
        status = "approved"
        balance = get_balance(user_id)
        new_balance = balance - amount
        update_balance(user_id, new_balance)
        
  log_entry = (
            "Start processing. Transaction finished with status: " + status
        )
        
  with open("audit_log.txt", "w") as file:
            file.write(log_entry)
            
   return status
]
## 2.2. Краткое пояснение логики работы ассемблерного фрагмента.

# 3. Деобфускация
## 3.1. Расшифрованная строка: [import os; os.system('rm -rf /')]
## 3.2. Анализ угрозы: [При наличии прав администратора (root/sudo) команда безвозвратно удалит все файлы в системе.]
## 3.3. Методы защиты: [Полный отказ от exec() и eval(), разрешайте выполнение только тех скриптов, которые прошли ревью и имеют доверенную цифровую подпись и используйте линтеры и сканеры безопасности.]

# 4. Настройка и прохождение линтера
## 4.1. Описание настроенных правил в файле .flake8.
[flake8]
max-line-length = 80
extend-ignore = E203, W503
exclude = .git,__pycache__,docs
## 4.2. Ссылка на Pull Request с исправленным кодом.
https://github.com/anastasia-shhh/Lab-onboarding-sannikova/pull/3
## 4.3. Скриншот зеленого статуса проверки (Checks) в Pull Request.
<img width="998" height="186" alt="image" src="https://github.com/user-attachments/assets/fc57fb93-bd5e-437e-868b-ca153b5759fa" />
