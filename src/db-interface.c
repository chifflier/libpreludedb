/*****
*
* Copyright (C) 2002 Krzysztof Zaraska <kzaraska@student.uci.agh.edu.pl>
* All Rights Reserved
*
* This file is part of the Prelude program.
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2, or (at your option)
* any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; see the file COPYING.  If not, write to
* the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
*
*****/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include <sys/types.h>

#include <libprelude/list.h>
#include <libprelude/prelude-log.h>
#include <libprelude/idmef-tree.h>
#include <libprelude/plugin-common.h>
#include <libprelude/plugin-common-prv.h>

#include "sql-table.h"
#include "sql-connection-data.h"
#include "sql.h"
#include "db-type.h"
#include "db-connection.h" 
#include "db-connection-data.h"
#include "db-interface.h"
#include "plugin-format.h"

struct prelude_db_interface {
	char *name;
	prelude_db_connection_t *db_connection;
	prelude_db_connection_data_t *connection_data;
	char *format_name;
	plugin_format_t *format;
	struct list_head filter_list;
	int active;
};



prelude_db_interface_t *prelude_db_interface_new(const char *name,
						 const char *format,
						 prelude_db_connection_data_t *data) 
{
        prelude_db_interface_t *interface;

	if ( ! data )
		return NULL;
		
        interface = calloc(1, sizeof(*interface));
        if ( ! interface ) {
                log(LOG_ERR, "memory exhausted.\n");
                return NULL;
        }
        
        interface->connection_data = data;
        
        if ( format ) {
        	interface->format = (plugin_format_t *) plugin_search_by_name(format);
        	if ( ! interface->format ) {
                	log(LOG_ERR, "couldn't find format plugin '%s'.\n", format);
                	free(interface);
                	return NULL;
        	}
        	interface->format_name = strdup(format);
        }
        
        if ( name ) 
        	interface->name = strdup(name);
        else
        	interface->name = strdup("(unnamed)");

	interface->active = 1;
        
	INIT_LIST_HEAD(&interface->filter_list);
        
        return interface;
}




char *prelude_db_interface_get_name(prelude_db_interface_t *db) 
{
        return db ? db->name : NULL;
}




char *prelude_db_interface_get_format(prelude_db_interface_t *db) 
{
        return db ? db->format_name : NULL;
}




int prelude_db_interface_connect(prelude_db_interface_t *db) 
{
        prelude_sql_connection_t *cnx;

	switch ( prelude_db_connection_data_get_type(db->connection_data) ) {

		case prelude_db_type_sql:
        		cnx = prelude_sql_connect(prelude_db_connection_data_get(db->connection_data));
        		if ( ! cnx ) {
                		log(LOG_ERR, "%s: SQL connection failed.\n", db->name);
                		return -1;
                	}
                	
                	db->db_connection = prelude_db_connection_new(
                		prelude_db_type_sql, cnx);
                	if ( ! db->db_connection ) {
                		log(LOG_ERR, "%s: error creating db_connection_t object\n", 
                			db->name);
                		return -1;
                	}
                	
                	break;
                	
                default:
                	log(LOG_ERR, "%s: unknown database type %d\n", db->name, 
                		prelude_db_connection_data_get_type(db->connection_data));
                	return -1;
        }

        db->active = 1;
        
        return 0;
}



int prelude_db_interface_activate(prelude_db_interface_t *interface)
{
	if ( ! interface )
		return -1; 
		
	if ( interface->active )
		return -2;
		
	interface->active = 1;
	
	return 0;
}


int prelude_db_interface_deactivate(prelude_db_interface_t *interface)
{
	if ( ! interface )
		return -1; 
		
	if ( ! interface->active )
		return -2;
		
	interface->active = 0;
	
	return 0;
}



#if 0
static int db_connection_add_filter(prelude_db_interface_t *conn, const char *filter)
{
	filter_plugin_t *filter;
	
	if (!conn)
		return -1;
		
	filter = (plugin_filter_t *) search_plugin_by_name(filter);
	if (!filter)
		return -2;
	
	list_add_tail(...);
}

static int db_connection_delete_filter(prelude_db_interface_t *conn, const char *filter);
#endif



int prelude_db_interface_write_idmef_message(prelude_db_interface_t *interface, const idmef_message_t *msg)
{
	if ( ! interface )
		return -1;
		
	if ( ! msg )
		return -2;
	
	if ( ! interface->db_connection )
		return -3;
	
	if ( ! interface->active )
		return -4;
	
	if ( ! interface->format )
		return -5;
	
	if ( ! interface->format->format_write )
		return -6;
		
	return interface->format->format_write(interface->db_connection, msg);
}




prelude_db_connection_t *prelude_db_interface_get_connection(prelude_db_interface_t *interface)
{
	return interface ? interface->db_connection : NULL;
}




prelude_db_connection_data_t *prelude_db_interface_get_connection_data(prelude_db_interface_t *interface)
{
	return interface ? interface->connection_data : NULL;
}




int prelude_db_interface_disconnect(prelude_db_interface_t *interface)
{
	int ret;

	if ( ! interface )
		return -1;
	
	if ( ! interface->db_connection )
		return -2;

	prelude_db_interface_deactivate(interface);
	
	switch ( prelude_db_connection_get_type(interface->db_connection) ) {
            
        	case prelude_db_type_sql:
         		prelude_sql_close(prelude_db_connection_get(interface->db_connection));
                	break;
                
        	default:
                	log(LOG_ERR, "%s: not supported connection type %d\n", interface->name, 
                		prelude_db_connection_get_type(interface->db_connection));
                	return -4;
	}

	prelude_db_connection_destroy(interface->db_connection);
	
	return 0;
}




int prelude_db_interface_destroy(prelude_db_interface_t *interface)
{
	if ( ! interface )
		return -1;
	
	if ( interface->db_connection )
		prelude_db_interface_disconnect(interface);
	
	prelude_db_connection_data_destroy(interface->connection_data);
	
	/* FIXME: when filters are implemented, destroy interface->filter_list here */
	
	if ( interface->name ) 
		free(interface->name);
		
	if ( interface->format_name )
		free(interface->format_name);
		
	free(interface);
	
	return 0;
}




