REM 7z <command> [<switch>...] <base_archive_name> [<arguments>...]
"C:\Program Files\7-Zip\7z.exe" a log.zip log\
REM Continue to delete LOG directory?
PAUSE
RMDIR LOG /S 
"C:\Program Files\7-Zip\7z.exe" a misc.zip .\*.bak .\*.cfg .\*.usp .\*.gzl .\*.eve .\*.def .\*.map .\*.dat .\*.lrr output.mdb HostEmulatedLocation.txt collat*.txt remote_results.txt SLAConfiguration.xml sum_data\ Data\
REM Continue to delete BAK, CFG and USP?
PAUSE
DEL *.bak
DEL *.cfg
DEL *.usp
DEL *.gzl
DEL *.eve
DEL *.def
DEL *.map
DEL *.dat
DEL *.lrr
DEL HostEmulatedLocation.txt 
DEL collat*.txt 
DEL remote_results.txt 
DEL SLAConfiguration.xml 
DEL output.mdb
RMDIR SUM_DATA /S 
RMDIR Data /S 