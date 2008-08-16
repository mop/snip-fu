require 'condition-parse-helper'

class ConditionParser
  def initialize(str)
    @to_parse = str
  end

  def evaluate
    remove_escaping_slashes(transform_result(@to_parse))
  end

  def remove_escaping_slashes(string)
    string.gsub('\:', ':').gsub('\?', '?').gsub('\(', '(').gsub('\)', ')')
  end

  def eval_condition(cond)
    if cond[0] == ""
      cond[2]
    else
      cond[1]
    end
  end

  def transform_result(string)
    conditions = collect_conditions(string)
    evaluate_conditions(string, conditions)
  end

  def evaluate_conditions(string, conditions)
    pos, str = conditions.inject([0, ""]) do |inj, elems|
      pos, str = inj
      pre    = string[pos, elems[0] - pos].chop
      middle = transform_result(eval_condition(elems[1, 3]))
      middle = middle.chop if middle =~ /[\(\)]$/
      [elems[4] + 1, str + pre + middle]
    end
    str += string[pos, string.size]
    str
  end

  def collect_conditions(string)
    ConditionParseHelper.run_machine(string).map do |cond|
      cond = cond.enum_with_index.map { |c, i| c || cond.compact.last }
      _if = if_clause(string, cond)
      _then = remove_special_chars(then_clause(string, cond))
      _else = remove_special_chars(else_clause(string, cond))
      [ cond[0] , _if, _then, _else || "", cond[3] ]
    end
  end

  def remove_special_chars(string)
    string.gsub(/([^\\]):$/, '\1').gsub(/^:/, '')
  end

  def if_clause(string, cond)
    string[cond[0] + 1, cond[1] - cond[0] - 1]
  end

  def then_clause(string, cond)
    string[cond[1] + 1, cond[2] - cond[1]] || ''
  end

  def else_clause(string, cond)
    string[cond[2] + 1, cond[3] - cond[2]] || ''
  end
end
