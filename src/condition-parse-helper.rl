module ConditionParseHelper

%%{
machine conditional_parser;

action brace_open {
	in_brace += 1
}

action brace_close {
  in_brace -= 1
	if in_brace == 0
    idx += 1
    conditions.last[idx] = fpc
	end
}

action question_mark {
	if in_brace == 1
		conditions << Array.new(4)
		conditions.last[0] = fpc
		idx = 0
	end
}

action colon {
	if in_brace == 1
		idx += 1
		conditions.last[idx] = fpc
	end
}

main := |*
	'\\:';
	'\\(';
	'\\)';
	'\\?';
	':' @colon;
	'(' @brace_open;
	')' @brace_close;
	'?' @question_mark;
  any;
 *|;

}%%

%% write data;

def self.run_machine(data)
	conditions = []
	idx = 0
	in_brace = 0
	%%write init;
	%%write exec;
  conditions
end
end
