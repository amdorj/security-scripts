@ECHO OFF

:: Marketing, ya know?
type liamdev.txt

:: Because I'm a "hacker"... or not
COLOR 0A

CLS

:: Check For Admin
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success!  You have admin rights!
    goto :admin
) else (
    echo Error!  You must run the script with admin rights!
    ::pause>nul
    ping -n 5 127.0.0.1 >nul
    GOTO END
)

:admin
:: Account Policies
echo Setting up account password policies...
net accounts /FORCELOGOFF:30 /MINPWLEN:8 /MAXPWAGE:90 /MINPWAGE:10 /UNIQUEPW:5
echo Password policies set!  Moving on...

::Check system Arch.
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

:: Disable Guest Acct
net user Guest | findstr Active | findstr Yes
if %errorlevel%==0 echo Guest account is active, deactivating
if %errorlevel%==1 echo Guest account is not active, so not deactivating
net user Guest /active:NO

:: Download MBSA
if %OS%==64BIT powershell -Command "Invoke-WebRequest https://download.microsoft.com/download/8/E/1/8E16A4C7-DD28-4368-A83A-282C82FC212A/MBSASetup-x64-EN.msi -OutFile MBSAx64-Setup-.msi"
if %OS%==32BIT powershell -Command "Invoke-WebRequest https://download.microsoft.com/download/8/E/1/8E16A4C7-DD28-4368-A83A-282C82FC212A/MBSASetup-x86-EN.msi -OutFile MBSAx86-Setup.msi"

if %OS%==32BIT MBSAx86-Setup.msi
if %OS%==64BIT MBSAx64-Setup.msi


:end
