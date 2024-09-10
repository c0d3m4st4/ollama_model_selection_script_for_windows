@echo off
setlocal enabledelayedexpansion

echo Ollama model selector

REM Initialize variables
set count=0
set skip=1  REM Set the number of lines to skip
set ollama_running=False

tasklist.exe /svc /fo list | (find.exe /i "ollama app.exe") >nul && set ollama_running=True|| set ollama_running=False

if !ollama_running!==True (
	CALL :ollama_running
) else (
	CALL :ollama_not_running
)

REM End of script
goto :eof

:ollama_running
	echo:
	echo Available models:
	echo:

	REM List available models and display them with numbers
	for /f "tokens=1,* delims=	" %%a in ('ollama list') do (
	    if !skip! GTR 0 (
	        REM Skip the number of lines defined in "skip" variable
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

	REM Add an extra option to exit
	echo:
	echo [0] Exit

	REM Ask the user to choose a model by number
	echo:
	set /p choice="Select a model by number: "

	REM Validate the choice
	if "%choice%"=="0" (
	    echo Exiting without selection.
	    goto :eof
	)

	if not defined model[%choice%] (
	    echo Invalid selection.
	    goto :eof
	)

	REM Run ollama with the selected model
	echo Running ollama with model !model[%choice%]!
	ollama run !model[%choice%]!

        REM Exit after exiting Ollama (/bye)
        goto :eof

	REM Keep the command window open after execution
	pause

:ollama_not_running
	echo:
	echo Ollama is not running. Executing it to get models list. Please wait... 
	start /B "" "ollama app.exe"
	echo:
	CALL :ollama_running
