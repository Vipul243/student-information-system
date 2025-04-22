@echo off
setlocal EnableDelayedExpansion

echo Checking if MongoDB is running...
powershell -Command "Test-NetConnection -ComputerName localhost -Port 27017 | Out-Null"
IF %ERRORLEVEL% EQU 0 (
    echo MongoDB is running.
) ELSE (
    echo MongoDB is not running. Please start MongoDB before running the application.
    echo You can typically start MongoDB with: net start MongoDB
    exit /b 1
)

:: Check if Maven is installed
where mvn >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Building project with Maven...
    mvn clean package

    echo Starting application...
    java -jar target\student-information-system-1.0.0-jar-with-dependencies.jar
) ELSE (
    echo Maven not found. Trying to build manually...

    if not exist target\classes (
        mkdir target\classes
    )

    where javac >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
        echo Compiling Java files...

        dir /b lib\*.jar >nul 2>&1
        IF %ERRORLEVEL% EQU 0 (
            set "CP="

            for %%f in (lib\*.jar) do (
                set "CP=!CP!lib\%%f;"
            )

            :: Optional: remove last semicolon if needed
            if defined CP (
                set "CP=!CP:~0,-1!"
            )

            javac -d target\classes -cp "!CP!" src\main\java\com\studentinfo\*.java src\main\java\com\studentinfo\db\*.java src\main\java\com\studentinfo\gui\*.java

            echo Starting application...
            java -cp "target\classes;!CP!" com.studentinfo.gui.MainFrame
        ) ELSE (
            echo MongoDB libraries not found in lib directory.
            echo Please run "mvn clean package" to download dependencies or place MongoDB Java driver jars in the lib directory.
            exit /b 1
        )
    ) ELSE (
        echo Java compiler not found. Please ensure you have JDK installed.
        exit /b 1
    )
)

endlocal
