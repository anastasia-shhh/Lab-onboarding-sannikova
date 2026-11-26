@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM ============================================================================
REM Тема: Диагностика и аудит клиентского компьютера (Часть 2)
REM Автор: Санникова Анастасия Дмитриевна
REM Дата: 26.11.2026
REM ============================================================================

set "REPORT=%~dp0pc_report.txt"
set "TEMP_RAW=%TEMP%\apps_raw.txt"
set "TEMP_APPS=%TEMP%\apps_list.txt"
set /a TOTAL_CATEGORIES=5
set /a REC_COUNT=0

for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-Date -Format 'dd.MM.yyyy HH:mm:ss'"') do set "NOW_DT=%%a"
if not defined NOW_DT set "NOW_DT=%DATE% %TIME%"

echo ============================================================================ > "%REPORT%"
echo ============================================================================
call :log "АУДИТ И ДИАГНОСТИКА КЛИЕНТСКОГО КОМПЬЮТЕРА"
call :log "Дата и время проверки: !NOW_DT!"
call :log "============================================================================"
call :log ""

REM --- БЛОК 1: Операционная система ---
echo [Выполнение] Сбор сведений об ОС и железе...
set "OS_NAME=" & set "OS_VER="
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption" 2^>nul') do set "OS_NAME=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Version" 2^>nul') do set "OS_VER=%%a"

call :log "[1. Операционная система]"
if defined OS_NAME (call :log "Название: !OS_NAME!") else (call :log "Название: Данные получить не удалось")
if defined OS_VER (call :log "Версия: !OS_VER!") else (call :log "Версия: Данные получить не удалось")
call :log ""

REM --- БЛОК 2: Процессор ---
set "CPU_NAME="
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name" 2^>nul') do set "CPU_NAME=%%a"

call :log "[2. Процессор]"
if defined CPU_NAME (call :log "Модель: !CPU_NAME!") else (call :log "Модель: Данные получить не удалось")
call :log ""

REM --- БЛОК 3: Оперативная память ---
set "TOTAL_RAM_KB=" & set "FREE_RAM_KB="
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize" 2^>nul') do set "TOTAL_RAM_KB=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory" 2^>nul') do set "FREE_RAM_KB=%%a"

call :log "[3. Оперативная память]"
if defined TOTAL_RAM_KB (set /a TOTAL_RAM_GB=!TOTAL_RAM_KB!/1048576 & call :log "Всего памяти: !TOTAL_RAM_GB! ГБ") else (call :log "Всего памяти: Данные получить не удалось")
if defined FREE_RAM_KB (set /a FREE_RAM_GB=!FREE_RAM_KB!/1048576 & call :log "Свободно памяти: !FREE_RAM_GB! ГБ") else (call :log "Свободно памяти: Данные получить не удалось")
call :log ""

REM --- БЛОК 4: Диск C ---
set "DISK_TOTAL_GB=" & set "DISK_FREE_GB="
for /f "delims=" %%a in ('powershell -NoProfile -Command "[math]::Floor((Get-CimInstance Win32_LogicalDisk | Where-Object DeviceID -eq 'C:').Size / 1073741824)" 2^>nul') do set "DISK_TOTAL_GB=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "[math]::Floor((Get-CimInstance Win32_LogicalDisk | Where-Object DeviceID -eq 'C:').FreeSpace / 1073741824)" 2^>nul') do set "DISK_FREE_GB=%%a"

call :log "[4. Диск C]"
if defined DISK_TOTAL_GB (call :log "Общий размер: !DISK_TOTAL_GB! ГБ") else (call :log "Общий размер: Данные получить не удалось")
if defined DISK_FREE_GB (call :log "Свободно места: !DISK_FREE_GB! ГБ") else (call :log "Свободно места: Данные получить не удалось")
call :log "----------------------------------------------------------------------------"
call :log ""

REM --- БЛОК 5: Список программ из 64- и 32-битных разделов реестра ---
echo [Выполнение] Опрос реестра установленных программ...
if exist "%TEMP_RAW%" del /f /q "%TEMP_RAW%" > nul 2>&1
if exist "%TEMP_APPS%" del /f /q "%TEMP_APPS%" > nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do echo %%b>> "%TEMP_RAW%"
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do echo %%b>> "%TEMP_RAW%"

if exist "%TEMP_RAW%" powershell -NoProfile -Command "Get-Content -Encoding UTF8 '%TEMP_RAW%' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } | Sort-Object -Unique | Set-Content -Encoding UTF8 '%TEMP_APPS%'" 2>nul

call :log "[5. Список установленных программ]"
if exist "%TEMP_APPS%" (
    for /f "usebackq delims=" %%a in ("%TEMP_APPS%") do call :log " - %%a"
) else (
    call :log "Не удалось получить список установленных программ."
)
call :log "----------------------------------------------------------------------------"
call :log ""

REM --- БЛОК 6: Аудит базового офисного ПО ---
echo [Выполнение] Анализ базового и излишнего ПО...
call :log "[6. РЕКОМЕНДАЦИИ ПО БАЗОВОМУ ОФИСНОМУ ПО]"
call :check_base "Офисный пакет" "Office LibreOffice OpenOffice МойОфис" "Для работы с документами рекомендуется установить LibreOffice или МойОфис."
call :check_base "Архиватор" "7-Zip WinRAR WinZip" "Для работы с почтовыми вложениями рекомендуется установить 7-Zip или WinRAR."
call :check_base "Чтение PDF" "Acrobat Foxit SumatraPDF" "Рекомендуется установить SumatraPDF или Adobe Acrobat Reader."
call :check_base "Антивирус" "Kaspersky ESET Dr.Web Defender" "Используется встроенный Windows Defender (рекомендуется проверить актуальность баз)."

REM Отдельная проверка браузера (т.к. Edge встроен в систему)
set "FOUND_APP="
for /f "delims=" %%a in ('findstr /i "Chrome Firefox Яндекс Yandex" "%TEMP_APPS%" 2^>nul') do if not defined FOUND_APP set "FOUND_APP=%%a"
if defined FOUND_APP (
    call :log "[OK] Браузер: требование выполнено (найдено: !FOUND_APP!)"
) else (
    set /a REC_COUNT+=1
    call :log "[i] Браузер: обнаружен только системный Microsoft Edge. Рекомендуется установить Яндекс.Браузер или Chrome."
)
call :log "----------------------------------------------------------------------------"
call :log ""

REM --- БЛОК 7: Аудит излишнего ПО (рекомендательный характер) ---
call :log "[7. РЕКОМЕНДАЦИИ ПО ПРОВЕРКЕ ИЗЛИШНЕГО ПО]"
call :log "Примечание: программы ниже не относятся к базовым офисным задачам и подлежат проверке администратором."
call :log ""
call :check_extra "Группа 1: Игровое ПО" "Steam Epic GOG Origin Ubisoft Battle.net Riot Game Gaming"
call :check_extra "Группа 2: Торрент-клиенты" "torrent uTorrent BitTorrent qBittorrent Vuze"
call :check_extra "Группа 3: Мессенджеры (уточнить использование в работе)" "Discord Telegram WhatsApp Viber Skype"
call :check_extra "Группа 4: Развлечения и медиа" "Wallpaper OBS Soundpad VLC PotPlayer AIMP"

REM --- БЛОК 8: Итоги и удаление временных файлов ---
call :log "============================================================================"
call :log "ИТОГИ: проверено категорий базового ПО — !TOTAL_CATEGORIES!, выдано рекомендаций — !REC_COUNT!"
call :log "Отчёт сохранён: %REPORT%"
call :log "============================================================================"

if exist "%TEMP_RAW%" del /f /q "%TEMP_RAW%" > nul 2>&1
if exist "%TEMP_APPS%" del /f /q "%TEMP_APPS%" > nul 2>&1
echo.
pause
exit /b 0

REM ==================== ПОДПРОГРАММЫ ====================

:check_base
set "FOUND_APP="
for /f "delims=" %%a in ('findstr /i "%~2" "%TEMP_APPS%" 2^>nul') do if not defined FOUND_APP set "FOUND_APP=%%a"
if defined FOUND_APP (
    call :log "[OK] %~1: требование выполнено (найдено: !FOUND_APP!)"
) else (
    set /a REC_COUNT+=1
    call :log "[!] %~1: не обнаружен. %~3"
)
exit /b

:check_extra
call :log "--- %~1 ---"
set "GROUP_FOUND="
for /f "delims=" %%a in ('findstr /i "%~2" "%TEMP_APPS%" 2^>nul') do (
    set "GROUP_FOUND=1"
    set /a REC_COUNT+=1
    call :log "  [?] К проверке: %%a"
)
if not defined GROUP_FOUND call :log "  Программ данной группы не обнаружено."
call :log ""
exit /b

:log
set "MSG=%~1"
if defined MSG (
    echo(!MSG!
    >> "%REPORT%" echo(!MSG!
) else (
    echo(
    >> "%REPORT%" echo(
)
exit /b
