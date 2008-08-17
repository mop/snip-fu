#include <glib.h>
#include <malloc.h>
#include "ragel-parser.h"

/**
 * This function is called when a snip-fu opening-tag is encountered. 
 * e.g. ${1:tag}
 */
static void push(parse_data *parse, int fpc);	
/**
 * This function is called when a regular opening tag (e.g. { ) is encountered.
 */
static void push_regular(parse_data *parse, int fpc);
/**
 * This function is called when a closing-tag is encountered (})
 */
static void pop(parse_data *parse, int fpc);

%%{
machine snippet_parser;

open_tag  = "${";
open_regular_tag = "{";
close_tag = "}";

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
	parse->depth += 1;
	if (parse->depth == 1) {
		int *array = malloc(sizeof(int) * ARRAY_SIZE);
		array[0] = fpc;
		parse->elements = g_list_append(parse->elements, array);
	}
}

void push_regular(parse_data *parse, int fpc)
{
	if (parse->depth >= 1)
		parse->depth += 1;
}

void pop(parse_data *parse, int fpc) 
{
	if (parse->depth == 1) {
		GList *elem = g_list_last(parse->elements);
		int *array = (int *)elem->data;
		array[ARRAY_SIZE - 1] = fpc;
	}
	if (parse->depth > 0) 
		parse->depth -= 1;
}

parse_data* parser_execute(const char *data, int len)
{
	parse_data *parse = malloc(sizeof(*parse));
	const char *p = data;
	const char *pe = data + len;

	parse->depth    = 0;
	parse->elements = NULL;

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
