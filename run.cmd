@echo off
:: Do some standard stuff to make batch files nicer
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

:: Set up default paths and ports needed by the avatar
IF NOT EXIST c:\data mkdir c:\data
IF NOT EXIST c:\skills mkdir c:\skills
set SSB_PORT=8997
set QWERT_PORT=7766

:: Handle user commands
if [%1]==[] goto:help
if %1==setup  node services\elife-stellar\pw goto:eof 
if %1==avatar  yarn start goto:eof 
if %1==gui yarn --cwd qwert\  start goto:eof 

:help
echo USAGE: %me% (command)
echo    where (command) = one of the commands below
echo            setup: Setup your node with a stellar password
echo            avatar: Start your avatar node
echo            gui: Run the default GUI client (QWERT)  
goto:eof
