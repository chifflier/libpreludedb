/*****
*
* Copyright (C) 2002 Krzysztof Zaraska <kzaraska@student.uci.agh.edu.pl>
* Copyright (C) 2003-2005 Nicolas Delon <nicolas@prelude-ids.org>
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

#ifndef _LIBPRELUDEDB_H
#define _LIBPRELUDEDB_H

#include <libprelude/prelude-inttypes.h>
#include <libprelude/idmef.h>

typedef struct preludedb preludedb_t;

typedef struct preludedb_result_idents preludedb_result_idents_t;
typedef struct preludedb_result_values preludedb_result_values_t;

typedef enum {
	PRELUDEDB_RESULT_IDENTS_ORDER_BY_NONE = 0,
	PRELUDEDB_RESULT_IDENTS_ORDER_BY_CREATE_TIME_DESC = 1,
	PRELUDEDB_RESULT_IDENTS_ORDER_BY_CREATE_TIME_ASC = 2
} preludedb_result_idents_order_t;


preludedb_t *preludedb_new(preludedb_sql_t *sql, const char *format_name);

void preludedb_destroy(preludedb_t *db);

const char *preludedb_get_format_name(preludedb_t *db);

int preludedb_connect(preludedb_t *db);
void preludedb_disconnect(preludedb_t *db);

int preludedb_format_set(preludedb_t *db, const char *format_name);
int preludedb_format_autodetect(preludedb_t *db);

int preludedb_reconnect(preludedb_t *db);

preludedb_sql_t *preludedb_get_sql(preludedb_t *db);

void preludedb_result_idents_destroy(preludedb_result_idents_t *result);
int preludedb_result_idents_get_next(preludedb_result_idents_t *result, uint64_t *ident);

void preludedb_result_values_destroy(preludedb_result_values_t *result);
int preludedb_result_values_get_next(preludedb_result_values_t *result, idmef_value_t ***values);

int preludedb_get_error(preludedb_t *db, preludedb_error_t error, char **output);

int preludedb_insert_message(preludedb_t *db, idmef_message_t *message);

preludedb_result_idents_t *preludedb_get_alert_idents(preludedb_t *db, idmef_criteria_t *criteria,
						      int limit, int offset,
						      preludedb_result_idents_order_t order);
preludedb_result_idents_t *preludedb_get_heartbeat_idents(preludedb_t *db, idmef_criteria_t *criteria,
							  int limit, int offset,
							  preludedb_result_idents_order_t order);

idmef_message_t *preludedb_get_alert(preludedb_t *interface, uint64_t ident);
idmef_message_t *preludedb_get_heartbeat(preludedb_t *db, uint64_t ident);

int preludedb_delete_alert(preludedb_t *db, uint64_t ident);
int preludedb_delete_heartbeat(preludedb_t *db, uint64_t ident);

preludedb_result_values_t *preludedb_get_values(preludedb_t *db, preludedb_object_selection_t *object_selection,
						idmef_criteria_t *criteria, int distinct, int limit, int offset);


#endif /* _LIBPRELUDEDB_H */