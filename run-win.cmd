@echo off
:: Do some standard stuff to make batch files nicer
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

:: Set up node_modules
IF NOT EXIST node_modules npm install

:: Pass control to run.js
node run.js %*
