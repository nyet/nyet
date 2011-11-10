MySQLTemplate()
{
	int rc = 0;

    MYSQL *db_connection; 
    MYSQL_RES *query_result; 
    MYSQL_ROW result_row; 
    
    char *server = "localhost";
    char *user = "root";
    char *password = "sqapassword"; 
    char *database = "LRDB";
    int port = 3306; // default MySQL port

	//static char *server_options[] = { "mysql_test", "--defaults-file=my.cnf" };
	//int num_elements = sizeof(server_options)/ sizeof(char *);
    
    lr_whoami(&vuser_id, &vuser_group, &scid);
	lr_message( "Group: %s, vuser id: %d, scenario id %d", vuser_group, vuser_id, scid);

	if (vuser_id == -1) {
		vuser_id = 1;
	}

	rc = lr_load_dll("C:\\Program Files\\MySQL\\MySQL Server 5.0\\lib\\opt\\libmysql.dll");
    // You should be able to find the MySQL DLL somewhere in your MySQL install directory.
    if (rc != 0) {
        lr_error_message("Could not load libmysql.dll");
        lr_abort();
    }
    
    // Allocate and initialise a new MySQL object
    db_connection = mysql_init(NULL);
    if (db_connection == NULL) {
        lr_error_message("Insufficient memory");
        return -1;
    }

	  // Connect to the database
    if (mysql_real_connect(db_connection, server, user, password, database, port, NULL, 0) == NULL) {
		lr_error_message("error on connect: %s\n", mysql_error(db_connection));
		return -1;
	}

    if (mysql_query(db_connection, "SELECT * FROM LATLogin;")!= 0) {
		lr_error_message("error on query: %s\n", mysql_error(db_connection));
		return -1;
	}

	if ((query_result = mysql_store_result(db_connection)) == NULL) {
		lr_error_message("error on store: %s\n", mysql_error(db_connection));
		return -1;
	}

    while (result_row = mysql_fetch_row(query_result)) {
		lr_output_message("%s - %s", result_row[0]);
	}
	mysql_free_result(query_result);
	

    // Free the MySQL object created by mysql_init
    mysql_close(db_connection);
	mysql_server_end();

	return 0;
}
