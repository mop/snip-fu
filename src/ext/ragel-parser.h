#ifndef _PARSER_H_
#define _PARSER_H_

#include <glib.h>

enum {
	ARRAY_SIZE = 2
};

typedef struct parse_input {
	const char *data;
	int data_length;
	const char *start;
	int start_length;
	const char *end;
	int end_length;
} parse_input;

typedef struct parse_data {
	int depth;
	GList *elements;
	parse_input *input;
} parse_data;

void parser_free(parse_data *data);
parse_data *parser_execute(parse_input *input);

#endif
