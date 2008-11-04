@echo off

rem The purpose of this Windows script is to let you use the etl command line with a non-gem version of AW-ETL (eg: unpacked gem, pistoned trunk).
rem Just add the current folder on top of your PATH variable to use it instead of the etl command provided with the gem release.

rem %~dp0 returns the absolute path where the current script is. We just append 'etl' to it, and forward all the arguments with %*

ruby "%~dp0etl" %*
