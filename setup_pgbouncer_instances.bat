@echo off
:: Check for bash command
bash --version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    echo Error: bash is not installed.
    exit /b 1
)

bash setup_pgbouncer_instances.sh