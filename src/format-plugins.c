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
#include <stdarg.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <dlfcn.h>
#include <errno.h>
#include <sys/time.h>
#include <inttypes.h>
#include <assert.h>

#include <libprelude/list.h>
#include <libprelude/prelude-log.h>
#include <libprelude/idmef-tree.h>
#include <libprelude/plugin-common.h>
#include <libprelude/plugin-common-prv.h>

#include "sql-table.h"
#include "plugin-sql.h"
#include "db-connection.h"
#include "plugin-format.h"

static plugin_format_t *format = NULL;
static LIST_HEAD(format_plugins_list);


/*
 *
 */
static int subscribe(plugin_container_t *pc) 
{
        log(LOG_INFO, "- Subscribing %s to active format plugins.\n", pc->plugin->name);
        format = (plugin_format_t *) pc->plugin;
        return plugin_add(pc, &format_plugins_list, NULL);
}


static void unsubscribe(plugin_container_t *pc) 
{
        log(LOG_INFO, "- Un-subscribing %s from active format plugins.\n", pc->plugin->name);
        format = NULL;
        plugin_del(pc);
}

/**
 * format_plugins_init:
 * @dirname: Pointer to a directory string.
 * @argc: Number of command line argument.
 * @argv: Array containing the command line arguments.
 *
 * Tell the DB plugins subsystem to load database format plugins from @dirname.
 *
 * Returns: 0 on success, -1 if an error occured.
 */
int format_plugins_init(const char *dirname, int argc, char **argv)
{
        int ret;
	
	ret = access(dirname, F_OK);
	if ( ret < 0 ) {
		if ( errno == ENOENT )
			return 0;
		log(LOG_ERR, "can't access %s.\n", dirname);
		return -1;
	}

        ret = plugin_load_from_dir(dirname, argc, argv, subscribe, unsubscribe);
        if ( ret < 0 ) {
                log(LOG_ERR, "couldn't load plugin subsystem.\n");
                return -1;
        }

        return ret;
}



/**
 * format_plugins_available:
 *
 * Returns: 0 if there are active format plugins, -1 otherwise.
 */
int format_plugins_available(void) 
{
        return list_empty(&format_plugins_list) ? -1 : 0;
}

