#include <glib.h>
#include <malloc.h>
#include <string.h>
#include <stdlib.h>
#include "ragel-parser.h"

/**
 * This function is called when a snip-fu opening-tag is encountered. 
 * e.g. ${1:tag}
 */
static void push(parse_data *parse, int fpc);	
/**
 * This function is called when a regular opening tag (e.g. { ) is 
 * encountered.
 */
static void push_regular(parse_data *parse, int fpc);
/**
 * This function is called when a closing-tag is encountered (})
 */
static void pop(parse_data *parse, int fpc);

/**
 * This returns TRUE if the parse-stream contains a correct start-tag
 */
static int is_correct_start_tag(parse_data *parse, int fpc);
/**
 * This returns TRUE if the parse-stream contains a correct end-tag
 */
static int is_correct_end_tag(parse_data *parse, int fpc);

%%{
machine snippet_parser;

open_tag  = ('$' [\{\[<%]);
open_regular_tag = [\{\[<%];
close_tag = [\}\]>%];

main := |*
      open_tag  @{ push(parse, fpc - data); };
      open_regular_tag @{ push_regular(parse, fpc - data); };
      close_tag @{ pop(parse, fpc - data); };
      any;
  *|;

}%%

%% write data;

void push(parse_data *parse, int fpc)
{
	if (!is_correct_start_tag(parse, fpc)) return;
	parse->depth += 1;
	if (parse->depth == 1) {
		int *array = malloc(sizeof(int) * ARRAY_SIZE);
		array[0] = fpc;
		parse->elements = g_list_append(parse->elements, array);
	}
}

void push_regular(parse_data *parse, int fpc)
{
	if (!is_correct_start_tag(parse, fpc)) return;
	if (parse->depth >= 1)
		parse->depth += 1;
}

void pop(parse_data *parse, int fpc) 
{
	if (!is_correct_end_tag(parse, fpc)) return;
	if (parse->depth == 1) {
		GList *elem = g_list_last(parse->elements);
		int *array = (int *)elem->data;
		array[ARRAY_SIZE - 1] = fpc;
	}
	if (parse->depth > 0) 
		parse->depth -= 1;
}

int is_correct_start_tag(parse_data *parse, int fpc)
{
	return strncmp(
		&parse->input->data[fpc],
		&parse->input->start[1],
		parse->input->start_length - 1
	) == 0;
}

int is_correct_end_tag(parse_data *parse, int fpc)
{
	return strncmp(
		&parse->input->data[fpc],
		parse->input->end,
		parse->input->end_length
	) == 0;
}

parse_data* parser_execute(parse_input *input)
{
	parse_data *parse = malloc(sizeof(*parse));
	const char *p     = input->data;
	const char *pe    = input->data + input->data_length;
	const char *data  = input->data;

	parse->depth    = 0;
	parse->elements = NULL;
	parse->input = input;

	int cs, act = 0;
	const char *tokstart, *tokend, *reg;
	%%write init;
	%%write exec;
	return parse;
}

void parser_free(parse_data *parser)
{
	for (GList *i = parser->elements; i; i = i->next)
		free(i->data);	// free the array
	g_list_free(parser->elements);
	free(parser);
}

/*
def self.run_machine(data)
  elements = []
  depth = 0
  %% write init;
  %% write exec;

  elements.map do |element|
    start, stop = element
    [start - 1, stop ]
  end
end
*/
