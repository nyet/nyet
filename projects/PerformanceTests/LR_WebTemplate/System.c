System()
{
	SystemAsync();
	SystemSync();
	return 0;
}


SystemAsync() {
	lr_start_transaction("LongRunning");
	system("longrunning_async_wrapper.bat");
	lr_end_transaction("LongRunning", LR_AUTO); //Duration < 1s
}

SystemSync() {
	lr_start_transaction("LongRunning");
    system("perl longrunning.pl"); 
	lr_end_transaction("LongRunning", LR_AUTO); //Duration: 10.0993
}
