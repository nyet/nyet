del /Q *.bak
del /Q *.log
del /Q *.idx
del /Q output.txt
del /Q combined_*.c
del /Q pre_cci.c
for /f "delims=" %%a IN ('dir /b "result*"') do rmdir /S /Q "%%a"