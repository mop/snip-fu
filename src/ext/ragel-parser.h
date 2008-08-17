#ifndef _PARSER_H_
#define _PARSER_H_

#include <glib.h>

enum {
	ARRAY_SIZE = 2
};

typedef struct parse_data {
	int depth;
	GList *elements;
} parse_data;


void parser_free(parse_data *data);
parse_data *parser_execute(const char *data, int len);

#endif
