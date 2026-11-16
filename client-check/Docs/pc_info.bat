@echo off
chcp 65001

echo ================================================== > "%REPORT%"
echo             ДИАГНОСТИКА КОМПЬЮТЕРА >> "%REPORT%"
echo ================================================== >> "%REPORT%"
echo. >> "%REPORT%"

REM 1. Сведения об операционной системе
echo --- Операционная система --- >> "%REPORT%"
for /f "tokens=1,* delims==" %%a in ('wmic os get Caption^,Version /format:list ^| findstr "="') do (
    if /i "%%a"=="Caption" echo Название: %%b >> "%REPORT%"
    if /i "%%a"=="Version" echo Версия: %%b >> "%REPORT%"
)
echo. >> "%REPORT%"

REM 2. Сведения о процессоре
echo --- Процессор --- >> "%REPORT%"
for /f "tokens=1,* delims==" %%a in ('wmic cpu get Name /format:list ^| findstr "="') do (
    echo Модель: %%b >> "%REPORT%"
)
echo. >> "%REPORT%"

REM 3. Сведения об оперативной памяти
echo --- Оперативная память --- >> "%REPORT%"
for /f "tokens=1,* delims==" %%a in ('wmic os get TotalVisibleMemorySize^,FreePhysicalMemory /format:list ^| findstr "="') do (
    if /i "%%a"=="TotalVisibleMemorySize" (
        set /a TOTAL_RAM=%%b / 1048576
    )
    if /i "%%a"=="FreePhysicalMemory" (
        set /a FREE_RAM=%%b / 1048576
    )
)
echo Всего памяти: !TOTAL_RAM! ГБ >> "%REPORT%"
echo Свободно памяти: !FREE_RAM! ГБ >> "%REPORT%"
echo. >> "%REPORT%"

REM 4. Свободное место на диске C 
echo --- Диск C --- >> "%REPORT%"
for /f "tokens=1,* delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size^,FreeSpace /format:list ^| findstr "="') do (
    if /i "%%a"=="Size" (
        set "RAW_SIZE=%%b"
        set "RAW_SIZE=!RAW_SIZE:~0,-6!"
        set /a TOTAL_DISK=!RAW_SIZE! / 1074
    )
    if /i "%%a"=="FreeSpace" (
        set "RAW_FREE=%%b"
        set "RAW_FREE=!RAW_FREE:~0,-6!"
        set /a FREE_DISK=!RAW_FREE! / 1074
    )
)
echo Общий размер: !TOTAL_DISK! ГБ >> "%REPORT%"
echo Свободно: !FREE_DISK! ГБ >> "%REPORT%"
echo. >> "%REPORT%"

REM 5. Список установленных программ
echo --- Установленные программы --- >> "%REPORT%"
(
    for /f "tokens=2,*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
        echo - %%b
    )
    for /f "tokens=2,*" %%a in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
        echo - %%b
    )
) | sort >> "%REPORT%"
echo. >> "%REPORT%"


echo ==================================================
echo Отчёт сохранён
echo ==================================================
echo.

pause
