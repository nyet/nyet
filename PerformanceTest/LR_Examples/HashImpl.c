#include "web_api.h"


HashImpl()
{
	int offset; 
    char * position; 
    char * str = "|FL|PA|TN|NH|NJ|"; 
    //char * search_str = "|CT|"; //"CT" was not found
	//char * search_str = "|KY|"; //"KY" was not found
	//char * search_str = "|FL|"; //"FL" was found at position 1
	//char * search_str = "|PA|"; //"PA" was found at position 4
	//char * search_str = "|TN|"; //"TN" was found at position 7
	//char * search_str = "|NH|"; //"NH" was found at position 10
	char * search_str = "|NJ|"; //"NJ" was found at position 13

	position = 0;
    position = (char *)strstr(str, search_str); 
    // strstr has returned the address. Now calculate * the offset from the beginning of str 
    offset = (int)(position - str + 1); 

	if (offset < 0) {
		lr_output_message ("\"%s\" was not found", search_str); 
	}
	else {
		lr_output_message ("\"%s\" was found at position %d", search_str, offset); 
	}

	return 0;
}
