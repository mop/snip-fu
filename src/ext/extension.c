#include <ruby.h>
#include <glib.h>
#include "ragel-parser.h"

VALUE TagParser = Qnil;
void Init_tag_parser();

static VALUE parse_tags(
	VALUE self,
	VALUE start_tag,
	VALUE end_tag,
	VALUE string
);

void Init_tag_parser()
{ 
	TagParser = rb_define_module("TagParser");
	rb_define_module_function(TagParser, "parse_tags", parse_tags, 3);
}

VALUE parse_tags(VALUE self, VALUE start_tag, VALUE end_tag, VALUE string)
{
	VALUE str = StringValue(string);
	VALUE start = StringValue(start_tag);
	VALUE end = StringValue(end_tag);
	parse_input input = (parse_input) {
		RSTRING(str)->ptr,   RSTRING(str)->len,
		RSTRING(start)->ptr, RSTRING(start)->len,
		RSTRING(end)->ptr,   RSTRING(end)->len
	};
	parse_data *p = parser_execute(&input);
	GList *list = p->elements;
	VALUE array = rb_ary_new2(g_list_length(list));
	for (GList *i = list; i; i = i->next) {
		int *data = (int *)i->data;
		VALUE pos = rb_ary_new2(ARRAY_SIZE);
		rb_ary_push(pos, INT2NUM(data[0]));
		rb_ary_push(pos, INT2NUM(data[1]));
		rb_ary_push(array, pos);
	}
	parser_free(p);
	return array;
}

