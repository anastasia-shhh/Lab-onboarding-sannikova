@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM ============================================================
REM Тема: Диагностика клиентского компьютера
REM Автор: Санникова Анастасия Дмитриевна
REM Дата: 26.11.2026
REM ============================================================

set "REPORT=%~dp0pc_report.txt"

REM Создание/очистка файла отчёта и вывод заголовка
(
    echo ============================================================
    echo Диагностика компьютера
    echo ============================================================
    echo.
) > "%REPORT%"

REM ------------------------------------------------------------
REM Блок 1: Сведения об операционной системе
REM ------------------------------------------------------------
(
    echo [Операционная система]
    for /f "tokens=1* delims==" %%a in ('wmic os get Caption^,Version /format:list ^| findstr "="') do (
        if "%%a"=="Caption" echo Название: %%b
        if "%%a"=="Version" echo Версия: %%b
    )
    echo.
    echo ------------------------------------------------------------
    echo.
) >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 2: Сведения о процессоре
REM ------------------------------------------------------------
(
    echo [Процессор]
    for /f "tokens=1* delims==" %%a in ('wmic cpu get Name /format:list ^| findstr "="') do (
        echo Модель: %%b
    )
    echo.
    echo ------------------------------------------------------------
    echo.
) >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 3: Сведения об оперативной памяти (перевод из КБ в ГБ)
REM ------------------------------------------------------------
for /f "tokens=1* delims==" %%a in ('wmic OS get TotalVisibleMemorySize^,FreePhysicalMemory /format:list ^| findstr "="') do (
    if "%%a"=="TotalVisibleMemorySize" set "TOTAL_RAM_KB=%%b"
    if "%%a"=="FreePhysicalMemory" set "FREE_RAM_KB=%%b"
)
set /a TOTAL_RAM_GB=!TOTAL_RAM_KB! / 1048576
set /a FREE_RAM_GB=!FREE_RAM_KB! / 1048576

(
    echo [Оперативная память]
    echo Всего памяти: !TOTAL_RAM_GB! ГБ
    echo Свободно памяти: !FREE_RAM_GB! ГБ
    echo.
    echo ------------------------------------------------------------
    echo.
) >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 4: Свободное место на диске C (перевод из байт в ГБ)
REM ------------------------------------------------------------
for /f "tokens=1* delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size^,FreeSpace /format:list ^| findstr "="') do (
    if "%%a"=="Size" set "DISK_TOTAL_B=%%b"
    if "%%a"=="FreeSpace" set "DISK_FREE_B=%%b"
)
REM Убираем последние 6 знаков (делим на 1 000 000), чтобы избежать 32-битного переполнения в set /a
set "DISK_TOTAL_MB=!DISK_TOTAL_B:~0,-6!"
set "DISK_FREE_MB=!DISK_FREE_B:~0,-6!"
set /a DISK_TOTAL_GB=!DISK_TOTAL_MB! / 1074
set /a DISK_FREE_GB=!DISK_FREE_MB! / 1074

(
    echo [Диск C]
    echo Общий размер: !DISK_TOTAL_GB! ГБ
    echo Свободно места: !DISK_FREE_GB! ГБ
    echo.
    echo ------------------------------------------------------------
    echo.
) >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 5: Список установленных программ (через реестр)
REM ------------------------------------------------------------
(
    echo [Установленные программы]
    for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
        echo - %%b
    )
    for /f "tokens=2*" %%a in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
        echo - %%b
    )
    echo.
    echo ============================================================
) >> "%REPORT%"

REM Вывод сформированного отчёта на экран и сообщение о завершении
type "%REPORT%"
echo.
echo Отчёт сохранён в файл: %REPORT%
echo.
pause
