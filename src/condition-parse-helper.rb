# line 1 "./condition-parse-helper.rl"
module ConditionParseHelper

# line 45 "./condition-parse-helper.rl"



# line 9 "./condition-parse-helper.rb"
class << self
	attr_accessor :_conditional_parser_actions
	private :_conditional_parser_actions, :_conditional_parser_actions=
end
self._conditional_parser_actions = [
	0, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 14, 1, 
	15, 2, 0, 11, 2, 1, 12, 2, 
	2, 13, 2, 3, 10
]

class << self
	attr_accessor :_conditional_parser_key_offsets
	private :_conditional_parser_key_offsets, :_conditional_parser_key_offsets=
end
self._conditional_parser_key_offsets = [
	0, 5
]

class << self
	attr_accessor :_conditional_parser_trans_keys
	private :_conditional_parser_trans_keys, :_conditional_parser_trans_keys=
end
self._conditional_parser_trans_keys = [
	40, 41, 58, 63, 92, 40, 41, 58, 
	63, 0
]

class << self
	attr_accessor :_conditional_parser_single_lengths
	private :_conditional_parser_single_lengths, :_conditional_parser_single_lengths=
end
self._conditional_parser_single_lengths = [
	5, 4
]

class << self
	attr_accessor :_conditional_parser_range_lengths
	private :_conditional_parser_range_lengths, :_conditional_parser_range_lengths=
end
self._conditional_parser_range_lengths = [
	0, 0
]

class << self
	attr_accessor :_conditional_parser_index_offsets
	private :_conditional_parser_index_offsets, :_conditional_parser_index_offsets=
end
self._conditional_parser_index_offsets = [
	0, 6
]

class << self
	attr_accessor :_conditional_parser_trans_targs_wi
	private :_conditional_parser_trans_targs_wi, :_conditional_parser_trans_targs_wi=
end
self._conditional_parser_trans_targs_wi = [
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_conditional_parser_trans_actions_wi
	private :_conditional_parser_trans_actions_wi, :_conditional_parser_trans_actions_wi=
end
self._conditional_parser_trans_actions_wi = [
	17, 20, 26, 23, 0, 13, 7, 9, 
	5, 11, 15, 0
]

class << self
	attr_accessor :_conditional_parser_to_state_actions
	private :_conditional_parser_to_state_actions, :_conditional_parser_to_state_actions=
end
self._conditional_parser_to_state_actions = [
	1, 0
]

class << self
	attr_accessor :_conditional_parser_from_state_actions
	private :_conditional_parser_from_state_actions, :_conditional_parser_from_state_actions=
end
self._conditional_parser_from_state_actions = [
	3, 0
]

class << self
	attr_accessor :conditional_parser_start
end
self.conditional_parser_start = 0;
class << self
	attr_accessor :conditional_parser_first_final
end
self.conditional_parser_first_final = 0;
class << self
	attr_accessor :conditional_parser_error
end
self.conditional_parser_error = -1;

class << self
	attr_accessor :conditional_parser_en_main
end
self.conditional_parser_en_main = 0;

# line 48 "./condition-parse-helper.rl"

def self.run_machine(data)
	conditions = []
	idx = 0
	in_brace = 0
	
# line 121 "./condition-parse-helper.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = conditional_parser_start
	tokstart = nil
	tokend = nil
	act = 0
end
# line 54 "./condition-parse-helper.rl"
	
# line 132 "./condition-parse-helper.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	if p != pe
	while true
	_break_resume = false
	begin
	_break_again = false
	_acts = _conditional_parser_from_state_actions[cs]
	_nacts = _conditional_parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _conditional_parser_actions[_acts - 1]
			when 5:
# line 1 "./condition-parse-helper.rl"
		begin
tokstart = p
		end
# line 1 "./condition-parse-helper.rl"
# line 153 "./condition-parse-helper.rb"
		end # from state action switch
	end
	break if _break_again
	_keys = _conditional_parser_key_offsets[cs]
	_trans = _conditional_parser_index_offsets[cs]
	_klen = _conditional_parser_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _conditional_parser_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _conditional_parser_trans_keys[_mid]
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
	  _klen = _conditional_parser_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _conditional_parser_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _conditional_parser_trans_keys[_mid+1]
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
	cs = _conditional_parser_trans_targs_wi[_trans]
	break if _conditional_parser_trans_actions_wi[_trans] == 0
	_acts = _conditional_parser_trans_actions_wi[_trans]
	_nacts = _conditional_parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _conditional_parser_actions[_acts - 1]
when 0:
# line 6 "./condition-parse-helper.rl"
		begin

	in_brace += 1
		end
# line 6 "./condition-parse-helper.rl"
when 1:
# line 10 "./condition-parse-helper.rl"
		begin

  in_brace -= 1
	if in_brace == 0
    idx += 1
    conditions.last[idx] = p
	end
		end
# line 10 "./condition-parse-helper.rl"
when 2:
# line 18 "./condition-parse-helper.rl"
		begin

	if in_brace == 1
		conditions << Array.new(4)
		conditions.last[0] = p
		idx = 0
	end
		end
# line 18 "./condition-parse-helper.rl"
when 3:
# line 26 "./condition-parse-helper.rl"
		begin

	if in_brace == 1
		idx += 1
		conditions.last[idx] = p
	end
		end
# line 26 "./condition-parse-helper.rl"
when 6:
# line 34 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 34 "./condition-parse-helper.rl"
when 7:
# line 35 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 35 "./condition-parse-helper.rl"
when 8:
# line 36 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 36 "./condition-parse-helper.rl"
when 9:
# line 37 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 37 "./condition-parse-helper.rl"
when 10:
# line 38 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 38 "./condition-parse-helper.rl"
when 11:
# line 39 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 39 "./condition-parse-helper.rl"
when 12:
# line 40 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 40 "./condition-parse-helper.rl"
when 13:
# line 41 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 41 "./condition-parse-helper.rl"
when 14:
# line 42 "./condition-parse-helper.rl"
		begin
tokend = p+1
		end
# line 42 "./condition-parse-helper.rl"
when 15:
# line 42 "./condition-parse-helper.rl"
		begin
tokend = p
p = p - 1;		end
# line 42 "./condition-parse-helper.rl"
# line 314 "./condition-parse-helper.rb"
		end # action switch
	end
	end while false
	break if _break_resume
	_acts = _conditional_parser_to_state_actions[cs]
	_nacts = _conditional_parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _conditional_parser_actions[_acts - 1]
when 4
# line 1 "./condition-parse-helper.rl"
		begin
tokstart = nil;		end
# line 1 "./condition-parse-helper.rl"
# line 331 "./condition-parse-helper.rb"
		end # to state action switch
	end
	p += 1
	break if p == pe
	end
	end
	end
# line 55 "./condition-parse-helper.rl"
  conditions
end
end
