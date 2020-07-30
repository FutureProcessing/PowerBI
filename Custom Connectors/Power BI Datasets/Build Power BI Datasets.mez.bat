@echo off

"7z.exe" a -aoa -tzip "Power BI Datasets.mez" ".\ConnectorFiles\*.*"

setlocal ENABLEEXTENSIONS
set KEY_NAME="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
set VALUE_NAME=Personal

FOR /F "usebackq skip=2 tokens=1-3" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME%`) DO (
    set ValueName=%%A
    set ValueType=%%B
    set ValueValue=%%C
)

xcopy /S /Q /Y /F "Power BI Datasets.mez" "%ValueValue%\Power BI Desktop\Custom Connectors\"