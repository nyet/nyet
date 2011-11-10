vuser_init()
{
	lr_whoami(&vuser_id, &vuser_group, &scid);
	lr_message( "Group: %s, vuser id: %d, scenario id %d", vuser_group, vuser_id, scid);

	if (vuser_id == -1) {
		vuser_id = 1;
	}

	lr_save_string("Adorno & Yoss, LLP", "pCompanyName");
	web_convert_param("pCompanyName_URL", 
		"SourceString={pCompanyName}", 
		"SourceEncoding=PLAIN", 
		"TargetEncoding=URL", 
		LAST);

	int msg_level;
	msg_level = lr_get_debug_message(); 

	lr_set_debug_message(LR_MSG_CLASS_BRIEF_LOG, LR_SWITCH_ON);

	return 0;
}

timestamp () {
	typedef long time_t;

	struct _timeb {
		time_t time;
		unsigned short millitm;
		short timezone;
		short dstflag;
	};

	struct _timeb t;

	_tzset(); // Sets variables used by ftime.

	ftime( &t);
	sprintf(tmptime, "%ld%u", t.time, t.millitm);
	lr_save_string(tmptime, "vUID");


	time_t tick; 
	time(&tick);
	// Get system time and display as number and string 
    //lr_message ("Time in seconds since 1/1/70: %ld\n", time(&t)); 
	lr_message ("Time in seconds since 1/1/70: %ld\n", tick); 

	//pTime per occurance is not stable (how to test this:?)

	// not sure about this one too
		lr_save_datetime("%m%%2F%d%%2F%Y", DATE_NOW, "pDate_URL"); 
		lr_output_message("pDate_URL: %s", lr_eval_string("{pDate_URL}")); 

}

match(const char *string, char *pattern, char *paramName, int matchnum) {
  // The match function will return 0 if match found
  //				  	   1 if match not found
  //					   2 if pattern incorrect
  // The match will be placed into parameter "{paramName}"
 
  int  status;
  int  eflag;
  char buf[1024] = "";
  char out[1024] = "";
 
  regex_t re;
  regmatch_t pmatch[128];
  lr_load_dll("pcre3.dll");
 
  if((status = regcomp(&re, pattern, REG_NEWLINE)) != 0){
    regerror(status, &re, buf, 120);
    lr_output_message("Match PCRE Exit 2");
    return 2;
  }
 
  if(status = regexec( &re, string, 10, pmatch, eflag) == 0) {
 
    strncpy(out, string + pmatch[matchnum].rm_so, pmatch[matchnum].rm_eo - pmatch[matchnum].rm_so);
    lr_save_string(out, paramName);
    eflag = REG_NOTBOL;
    regfree(&re);
    string = "";
    return 0;
  } else {
    lr_log_message("Match not found");
    // match not found
    regfree(&re);
    string = "";
    return 1;
  }
}
 
replace(const char *string, char *pattern, char *replace, char *paramName) {
  int length;
  int  status;
  int  eflag;
  char buf[1024] = "";
  char out[1024] = "";
 
  regex_t re;
  regmatch_t pmatch[128];
  lr_load_dll("pcre3.dll");
 
  if((status = regcomp(&re, pattern, REG_DOTALL)) != 0){
    regerror(status, &re, buf, 120);
    lr_output_message("Match PCRE Exit 2");
    return 2;
  }
 
  while(status = regexec( &re, string, 1, pmatch, eflag)== 0){
    //lr_output_message("match found at: %d, string=%s\n",
    //		pmatch[0].rm_so, string + pmatch[0].rm_so);
 
    strncat(out, string, pmatch[0].rm_so);
    strcat(out, replace);
    string += pmatch[0].rm_eo;
    eflag = REG_NOTBOL;
  }
  strcat(out, string);
  lr_save_string(out, paramName);
}

	



char *rtrim(char * string) 
{
	lr_output_message("String length: %d", strlen(string));
	lr_output_message("The last occurrence of <space>: |%s|", strrchr(string, ' '));

    while (strcmp(strrchr(string, ' '), " ") == 0) {
		lr_output_message("String length: %d", strlen(string));
		string[strlen(string)-1] = 0;
	}

	lr_output_message("String length: %d", strlen(string));
	lr_output_message("The string: |%s|", string);

	return string;
}

int isStringDigit(char *sText){
	int i = 0;
	unsigned int len = 0;

	len = strlen(sText);
	for (i=0;i<len;i++) {
		lr_output_message("%d", sText[i]);
        if (!isdigit(sText[i])) {
			lr_output_message("sText[%d] (%c) is a not digit:%d", i, sText[i], sText[i]);
			return 0;
		}
	}
	return 1;
}
