@echo off
setlocal enabledelayedexpansion

echo --- Ollama model selector ---
echo:

:: Initialize variables
set count=0
:: Number of lines to skip from the output
set skip=1
set ollama_running=False

tasklist.exe /svc /fo list | (find.exe /i "ollama app.exe") >nul && set ollama_running=True|| set ollama_running=False

if !ollama_running!==True (
	CALL :ollama_running
) else (
	CALL :ollama_not_running
)

:: End of script
goto :eof

:ollama_running

	:: Get current ollama version
	for /f "tokens=4 delims= " %%a in ('ollama -v') do (
	    set version=%%a
	)

	:: Trim leading/trailing spaces
	set version=%version: =%

	echo Current ollama version is %version%

	echo:
	echo Available models:
	echo:

	:: List available models and display a numbered menu
	for /f "tokens=1,* delims=	" %%a in ('ollama list') do (
	    if !skip! GTR 0 (
	        :: Skip the number of lines defined in "skip" variable
	        set /a skip-=1
	    ) else (
	        if not "%%a"=="" (
	            if !count! GTR 0 (
	            	echo [!count!] %%a %%b
		        set "model[!count!]=%%a"
		    ) else (
	            	echo     %%a %%b
		    )		
	            set /a count+=1
	        )
	    )
	)

	:: Add an extra option to exit
	echo:
	echo [0] Exit

	echo:
	set /p choice="Select a model by number: "

	:: Validate choice
	if "%choice%"=="0" (
	    echo Exiting without selection.
	    goto :eof
	)

	if not defined model[%choice%] (
	    echo Invalid selection.
	    goto :eof
	)

	:: Run ollama with the selected model
	echo Running ollama with model !model[%choice%]!
	ollama run !model[%choice%]!

        :: Exit after exiting Ollama (/bye)
        goto :eof

	pause

:ollama_not_running
	echo:
	echo Ollama is not running. Executing it to get models list. Please wait... 
	start /B "" "ollama app.exe"
	:: Timeout to give it time to start or the version number won't get displayed
	timeout /t 2 /nobreak >nul
	echo:
	CALL :ollama_running
