SystemOpen()
{
extern char* strtok(char *token, const char *delimiter); // Explicit declaration required for functions that do not return an int.
 
#define BUFFER_SIZE 10240 // 10 KB
 
Action3()
{
    long fp; // file/stream pointer
    int count; // number of characters that have been read from the stream.
    char buffer[BUFFER_SIZE]; // allocate memory for the output of the command.
    char * token;
    char param_buf[10]; // buffer to hold the parameter name.
    int i;
 
    /*
     * Running a command, and splitting the output into separate parameters for each element.
     */ 
 
    // "DIR /B" gives a "bare" directory listing (in this case, of the files in the VuGen script directory).
    fp = popen("perl C:\\PerformanceTest\\TRAX\\Scripts\\LATPackets\\test.pl", "r");
    if (fp == NULL) {
        lr_error_message("Error opening stream.");
        return -1;
    }
 
    count = fread(buffer, sizeof(char), BUFFER_SIZE, fp); // read up to 10KB
    if (feof(fp) == 0) {
        lr_error_message("Did not reach the end of the input stream when reading. Try increasing BUFFER_SIZE.");
        return -1;
    }
    if (ferror(fp)) {
        lr_error_message ("I/O error during read."); 
        return -1;
    }
    buffer[count] = NULL;
 
    // Split the stream at each newline character, and save them to a parameter array.
    token = (char*) strtok(buffer, "\n"); // Get the first token 
 
    if (token == NULL) { 
        lr_error_message ("No tokens found in string!"); 
        return -1; 
    }
 
    i = 1;
    while (token != NULL) { // While valid tokens are returned 
        sprintf(param_buf, "output_%d", i);
        lr_save_string(token, param_buf);
        i++;
        token = (char*) strtok(NULL, "\n"); 
    }
    lr_save_int(i-1, "output_count");
 
    // Print all values of the parameter array.
    for (i=1; i<=lr_paramarr_len("output"); i++) {
        lr_output_message("Parameter value: %s", lr_paramarr_idx("output", i));
    }
 
    pclose(fp);

	return 0;
}

//http://www.myloadtest.com/dos-commands-from-loadrunner/

	return 0;
}
