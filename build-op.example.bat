@echo off

:: Set here your path to 7-Zip, including 7z.exe
SET zip="C:\Program Files\7-Zip\7z.exe"
%zip% a -mx1 -tzip Speedrun.op info.toml src