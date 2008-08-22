#line 1 "./ragel-parser.rl"
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

#line 45 "./ragel-parser.rl"



#line 37 "./ragel-parser.c"
static const char _snippet_parser_actions[] = {
	0, 1, 3, 1, 4, 1, 8, 1, 
	9, 2, 0, 5, 2, 1, 6, 2, 
	2, 7, 3, 1, 6, 2
};

static const char _snippet_parser_key_offsets[] = {
	0, 8
};

static const char _snippet_parser_trans_keys[] = {
	36, 37, 60, 62, 91, 93, 123, 125, 
	37, 60, 91, 123, 0
};

static const char _snippet_parser_single_lengths[] = {
	8, 4
};

static const char _snippet_parser_range_lengths[] = {
	0, 0
};

static const char _snippet_parser_index_offsets[] = {
	0, 9
};

static const char _snippet_parser_trans_targs_wi[] = {
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0
};

static const char _snippet_parser_trans_actions_wi[] = {
	0, 18, 12, 15, 12, 15, 12, 15, 
	5, 9, 9, 9, 9, 7, 0
};

static const char _snippet_parser_to_state_actions[] = {
	1, 0
};

static const char _snippet_parser_from_state_actions[] = {
	3, 0
};

static const int snippet_parser_start = 0;
static const int snippet_parser_first_final = 0;
static const int snippet_parser_error = -1;

static const int snippet_parser_en_main = 0;

#line 48 "./ragel-parser.rl"

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
	
#line 153 "./ragel-parser.c"
	{
	cs = snippet_parser_start;
	tokstart = 0;
	tokend = 0;
	act = 0;
	}
#line 111 "./ragel-parser.rl"
	
#line 162 "./ragel-parser.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _out;
_resume:
	_acts = _snippet_parser_actions + _snippet_parser_from_state_actions[cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 ) {
		switch ( *_acts++ ) {
	case 4:
#line 1 "./ragel-parser.rl"
	{tokstart = p;}
	break;
#line 181 "./ragel-parser.c"
		}
	}

	_keys = _snippet_parser_trans_keys + _snippet_parser_key_offsets[cs];
	_trans = _snippet_parser_index_offsets[cs];

	_klen = _snippet_parser_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _snippet_parser_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	cs = _snippet_parser_trans_targs_wi[_trans];

	if ( _snippet_parser_trans_actions_wi[_trans] == 0 )
		goto _again;

	_acts = _snippet_parser_actions + _snippet_parser_trans_actions_wi[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 39 "./ragel-parser.rl"
	{ push(parse, p - data); }
	break;
	case 1:
#line 40 "./ragel-parser.rl"
	{ push_regular(parse, p - data); }
	break;
	case 2:
#line 41 "./ragel-parser.rl"
	{ pop(parse, p - data); }
	break;
	case 5:
#line 39 "./ragel-parser.rl"
	{tokend = p+1;}
	break;
	case 6:
#line 40 "./ragel-parser.rl"
	{tokend = p+1;}
	break;
	case 7:
#line 41 "./ragel-parser.rl"
	{tokend = p+1;}
	break;
	case 8:
#line 42 "./ragel-parser.rl"
	{tokend = p+1;}
	break;
	case 9:
#line 42 "./ragel-parser.rl"
	{tokend = p;p--;}
	break;
#line 277 "./ragel-parser.c"
		}
	}

_again:
	_acts = _snippet_parser_actions + _snippet_parser_to_state_actions[cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 ) {
		switch ( *_acts++ ) {
	case 3:
#line 1 "./ragel-parser.rl"
	{tokstart = 0;}
	break;
#line 290 "./ragel-parser.c"
		}
	}

	if ( ++p != pe )
		goto _resume;
	_out: {}
	}
#line 112 "./ragel-parser.rl"
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
