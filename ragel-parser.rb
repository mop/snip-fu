# line 1 "./ragel-parser.rl"
@elements = []
@depth = 0
@mark  = -1

# line 34 "./ragel-parser.rl"



# line 11 "./ragel-parser.rb"
class << self
	attr_accessor :_snippet_parser_actions
	private :_snippet_parser_actions, :_snippet_parser_actions=
end
self._snippet_parser_actions = [
	0, 1, 3, 1, 4, 1, 8, 1, 
	9, 2, 0, 5, 2, 1, 6, 2, 
	2, 7
]

class << self
	attr_accessor :_snippet_parser_key_offsets
	private :_snippet_parser_key_offsets, :_snippet_parser_key_offsets=
end
self._snippet_parser_key_offsets = [
	0, 3
]

class << self
	attr_accessor :_snippet_parser_trans_keys
	private :_snippet_parser_trans_keys, :_snippet_parser_trans_keys=
end
self._snippet_parser_trans_keys = [
	36, 123, 125, 123, 0
]

class << self
	attr_accessor :_snippet_parser_single_lengths
	private :_snippet_parser_single_lengths, :_snippet_parser_single_lengths=
end
self._snippet_parser_single_lengths = [
	3, 1
]

class << self
	attr_accessor :_snippet_parser_range_lengths
	private :_snippet_parser_range_lengths, :_snippet_parser_range_lengths=
end
self._snippet_parser_range_lengths = [
	0, 0
]

class << self
	attr_accessor :_snippet_parser_index_offsets
	private :_snippet_parser_index_offsets, :_snippet_parser_index_offsets=
end
self._snippet_parser_index_offsets = [
	0, 4
]

class << self
	attr_accessor :_snippet_parser_trans_targs_wi
	private :_snippet_parser_trans_targs_wi, :_snippet_parser_trans_targs_wi=
end
self._snippet_parser_trans_targs_wi = [
	1, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_snippet_parser_trans_actions_wi
	private :_snippet_parser_trans_actions_wi, :_snippet_parser_trans_actions_wi=
end
self._snippet_parser_trans_actions_wi = [
	0, 12, 15, 5, 9, 7, 0
]

class << self
	attr_accessor :_snippet_parser_to_state_actions
	private :_snippet_parser_to_state_actions, :_snippet_parser_to_state_actions=
end
self._snippet_parser_to_state_actions = [
	1, 0
]

class << self
	attr_accessor :_snippet_parser_from_state_actions
	private :_snippet_parser_from_state_actions, :_snippet_parser_from_state_actions=
end
self._snippet_parser_from_state_actions = [
	3, 0
]

class << self
	attr_accessor :snippet_parser_start
end
self.snippet_parser_start = 0;
class << self
	attr_accessor :snippet_parser_first_final
end
self.snippet_parser_first_final = 0;
class << self
	attr_accessor :snippet_parser_error
end
self.snippet_parser_error = -1;

class << self
	attr_accessor :snippet_parser_en_main
end
self.snippet_parser_en_main = 0;

# line 37 "./ragel-parser.rl"

def run_machine(data)
  
# line 116 "./ragel-parser.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = snippet_parser_start
	tokstart = nil
	tokend = nil
	act = 0
end
# line 40 "./ragel-parser.rl"
  
# line 127 "./ragel-parser.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	if p != pe
	while true
	_break_resume = false
	begin
	_break_again = false
	_acts = _snippet_parser_from_state_actions[cs]
	_nacts = _snippet_parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _snippet_parser_actions[_acts - 1]
			when 4:
# line 1 "./ragel-parser.rl"
		begin
tokstart = p
		end
# line 1 "./ragel-parser.rl"
# line 148 "./ragel-parser.rb"
		end # from state action switch
	end
	break if _break_again
	_keys = _snippet_parser_key_offsets[cs]
	_trans = _snippet_parser_index_offsets[cs]
	_klen = _snippet_parser_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _snippet_parser_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _snippet_parser_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _snippet_parser_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _snippet_parser_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _snippet_parser_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _snippet_parser_trans_targs_wi[_trans]
	break if _snippet_parser_trans_actions_wi[_trans] == 0
	_acts = _snippet_parser_trans_actions_wi[_trans]
	_nacts = _snippet_parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _snippet_parser_actions[_acts - 1]
when 0:
# line 8 "./ragel-parser.rl"
		begin
 
	@depth += 1
	@elements << [p] if @depth == 1
		end
# line 8 "./ragel-parser.rl"
when 1:
# line 13 "./ragel-parser.rl"
		begin

	@depth += 1
		end
# line 13 "./ragel-parser.rl"
when 2:
# line 17 "./ragel-parser.rl"
		begin

	@elements.last << p if @depth == 1
	@depth -= 1
		end
# line 17 "./ragel-parser.rl"
when 5:
# line 28 "./ragel-parser.rl"
		begin
tokend = p+1
		end
# line 28 "./ragel-parser.rl"
when 6:
# line 29 "./ragel-parser.rl"
		begin
tokend = p+1
		end
# line 29 "./ragel-parser.rl"
when 7:
# line 30 "./ragel-parser.rl"
		begin
tokend = p+1
		end
# line 30 "./ragel-parser.rl"
when 8:
# line 31 "./ragel-parser.rl"
		begin
tokend = p+1
		end
# line 31 "./ragel-parser.rl"
when 9:
# line 31 "./ragel-parser.rl"
		begin
tokend = p
p = p - 1;		end
# line 31 "./ragel-parser.rl"
# line 263 "./ragel-parser.rb"
		end # action switch
	end
	end while false
	break if _break_resume
	_acts = _snippet_parser_to_state_actions[cs]
	_nacts = _snippet_parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _snippet_parser_actions[_acts - 1]
when 3
# line 1 "./ragel-parser.rl"
		begin
tokstart = nil;		end
# line 1 "./ragel-parser.rl"
# line 280 "./ragel-parser.rb"
		end # to state action switch
	end
	p += 1
	break if p == pe
	end
	end
	end
# line 41 "./ragel-parser.rl"
end
