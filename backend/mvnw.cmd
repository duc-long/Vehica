@REM ----------------------------------------------------------------------------
@REM Maven Wrapper Batch Script with Auto-Bootstrap
@REM ----------------------------------------------------------------------------
@IF "%DEBUG%" == "" @ECHO OFF
@SETLOCAL

SET "MVN_VERSION=3.9.9"
SET "MVN_HOME=%USERPROFILE%\.m2\wrapper\dists\apache-maven-%MVN_VERSION%\apache-maven-%MVN_VERSION%"
SET "MVN_CMD=%MVN_HOME%\bin\mvn.cmd"

IF NOT EXIST "%MVN_CMD%" (
    ECHO Installing Maven %MVN_VERSION% wrapper...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$zip = '%TEMP%\apache-maven.zip'; " ^
        "$dest = '%USERPROFILE%\.m2\wrapper\dists\apache-maven-%MVN_VERSION%'; " ^
        "if (!(Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }; " ^
        "Invoke-WebRequest -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/%MVN_VERSION%/apache-maven-%MVN_VERSION%-bin.zip' -OutFile $zip; " ^
        "Expand-Archive -Path $zip -DestinationPath $dest -Force; " ^
        "Remove-Item $zip -Force"
)

IF EXIST "%MVN_CMD%" (
    CALL "%MVN_CMD%" %*
) ELSE (
    ECHO Failed to bootstrap Maven.
    EXIT /B 1
)

@ENDLOCAL
