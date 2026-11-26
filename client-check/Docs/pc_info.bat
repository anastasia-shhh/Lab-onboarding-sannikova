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
echo ============================================================ > "%REPORT%"
echo Диагностика компьютера >> "%REPORT%"
echo ============================================================ >> "%REPORT%"
echo. >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 1: Сведения об операционной системе
REM ------------------------------------------------------------
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"') do set "OS_NAME=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Version"') do set "OS_VER=%%a"

echo [Операционная система] >> "%REPORT%"
echo Название: !OS_NAME! >> "%REPORT%"
echo Версия: !OS_VER! >> "%REPORT%"
echo. >> "%REPORT%"
echo ------------------------------------------------------------ >> "%REPORT%"
echo. >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 2: Сведения о процессоре
REM ------------------------------------------------------------
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name"') do set "CPU_NAME=%%a"

echo [Процессор] >> "%REPORT%"
echo Модель: !CPU_NAME! >> "%REPORT%"
echo. >> "%REPORT%"
echo ------------------------------------------------------------ >> "%REPORT%"
echo. >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 3: Сведения об оперативной памяти (перевод из КБ в ГБ)
REM ------------------------------------------------------------
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize"') do set "TOTAL_RAM_KB=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory"') do set "FREE_RAM_KB=%%a"

set /a TOTAL_RAM_GB=!TOTAL_RAM_KB! / 1048576
set /a FREE_RAM_GB=!FREE_RAM_KB! / 1048576

echo [Оперативная память] >> "%REPORT%"
echo Всего памяти: !TOTAL_RAM_GB! ГБ >> "%REPORT%"
echo Свободно памяти: !FREE_RAM_GB! ГБ >> "%REPORT%"
echo. >> "%REPORT%"
echo ------------------------------------------------------------ >> "%REPORT%"
echo. >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 4: Свободное место на диске C (перевод из байт в ГБ)
REM ------------------------------------------------------------
for /f "delims=" %%a in ('powershell -NoProfile -Command "[math]::Floor((Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\").Size / 1073741824)"') do set "DISK_TOTAL_GB=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "[math]::Floor((Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\").FreeSpace / 1073741824)"') do set "DISK_FREE_GB=%%a"

echo [Диск C] >> "%REPORT%"
echo Общий размер: !DISK_TOTAL_GB! ГБ >> "%REPORT%"
echo Свободно места: !DISK_FREE_GB! ГБ >> "%REPORT%"
echo. >> "%REPORT%"
echo ------------------------------------------------------------ >> "%REPORT%"
echo. >> "%REPORT%"

REM ------------------------------------------------------------
REM Блок 5: Список установленных программ (через реестр)
REM ------------------------------------------------------------
echo [Установленные программы] >> "%REPORT%"
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
    echo - %%b >> "%REPORT%"
)
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
    echo - %%b >> "%REPORT%"
)
echo. >> "%REPORT%"
echo ============================================================ >> "%REPORT%"

REM Вывод сформированного отчёта на экран и сообщение о завершении
type "%REPORT%"
echo.
echo Отчёт сохранён в файл: %REPORT%
echo.
pause
