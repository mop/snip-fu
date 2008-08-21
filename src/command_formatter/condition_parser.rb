require File.dirname(__FILE__) + '/condition-parse-helper'

# This class is responsible for parsing regexp-translation-conditions. 
# A translation-condition is e.g. $VAR/(some)(.*)/(?1:$2)/, which prints
# the second group if the first-group (some) matches.
# ---
# @package
class ConditionParser
  # Initializes the ConditionParser-object with the given string (= the
  # condition which should be parsed)
  #
  # ==== Parameters
  # str<String>::
  #   The condition which should be parsed
  def initialize(str)
    @to_parse = str
  end

  # Evaluates recursively the condition-expression and return the result as a
  # string.
  #
  # ==== Returns
  # String::
  #   The result of the condition-expression is returned.
  def evaluate
    remove_escaping_slashes(transform_result(@to_parse))
  end
  private

  # This method removes the escaping backslashes from :, ?, ( and ).
  #
  # ==== Parameters
  # string<String>::
  #   The final result string, whose backslashes should be removed.
  #
  # ==== Returns
  # String:: 
  #   The cleaned string is returned.
  def remove_escaping_slashes(string)
    string.gsub('\:', ':').gsub('\?', '?').gsub('\(', '(').gsub('\)', ')')
  end

  # Evaluates the given condition and returns the result as string.
  #
  # ==== Parameter
  # cond<Array[_if<String>, _then<String>, _else<String>]>::
  #   a Array with 3 elements representing the if-clause, then-clause and
  #   else-clause of the condition.
  #
  # ==== Returns
  # String::
  #   Either the _then-clause or the _else-clause is returned, depending on the
  #   value of the _if-clause.
  def eval_condition(cond)
    if cond[0] == ""
      cond[2]
    else
      cond[1]
    end
  end

  # Transforms the given string by searching it for conditions and evaluating
  # them recusively.
  #
  # ==== Parameters
  # string<String>:: 
  #   The string which should be searched for conditions
  #
  # ==== Returns
  # String::
  #   The result of the condition is returned. If there are some regular
  #   text-elements between the condition-elements, they will be
  #   appended/prepended to the appropriate results of the
  #   conditional-expressions.
  def transform_result(string)
    conditions = collect_conditions(string)
    evaluate_conditions(string, conditions)
  end

  # Evaluates the given conditions in the given string.
  #
  # ==== Parameters
  # string<String>::
  #   The original string, in which the conditions were found.
  # conditions<Array[Array[
  #   start_pos<Fixnum>,
  #   _if<String>,
  #   _then<String>,
  #   _else<String>,
  #   end_pos<Fixnum>
  # ]]>::
  #   An array of conditions, which are represented as an array with a size of
  #   5, which includes the start-position, the if-, then- and else-clause of
  #   the condition and the end-position of the condition.
  #
  # ==== Returns
  # String::
  #   The evaluated string is returned.
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

  # Collects the conditions as array of arrays in the given string.
  #
  # ==== Parameters
  # string<String>::
  #   The string which should be searched for conditions.
  #
  # ==== Returns
  # Array[Array[
  #   start_pos<Fixnum>,
  #   _if<String>,
  #   _then<String>,
  #   _else<String>,
  #   end_pos<Fixnum>
  # ]]::
  #   An array of conditions, which are represented as an array with a size of
  #   5, which includes the start-position, the if-, then- and else-clause of
  #   the condition and the end-position of the condition.
  def collect_conditions(string)
    ConditionParseHelper.run_machine(string).map do |cond|
      cond = cond.enum_with_index.map { |c, i| c || cond.compact.last }
      _if = if_clause(string, cond)
      _then = remove_special_chars(then_clause(string, cond))
      _else = remove_special_chars(else_clause(string, cond))
      [ cond[0] , _if, _then, _else || "", cond[3] ]
    end
  end

  # removes the colons (:) from the given string, if they are _not_ escaped.
  # This is necessary because the sub-elements which are returned from
  # then_clause and else_clause might contain a colon before/after the
  # expression, which should be removed.
  #
  # ==== Parameters
  # string<String>::
  #   The string in which the colons should be removed.
  #
  # ==== Returns
  # String:: 
  #   A new string without colons at the beginning and end is returned.
  def remove_special_chars(string)
    string.gsub(/([^\\]):$/, '\1').gsub(/^:/, '')
  end

  # Returns the if-clause of the given condition in the given string.
  #
  # ==== Parameters
  # string<String>::
  #   The string from which the given condition was extracted.
  # cond<Array[Fixnum, Fixnum, Fixnum, Fixnum]>::
  #   An array containing the start and stop-positions of the condition and
  #   it's if, then and else-clauses in the string.
  def if_clause(string, cond)
    string[cond[0] + 1, cond[1] - cond[0] - 1]
  end

  # Returns the then-clause of the given condition in the given string.
  #
  # ==== Parameters
  # string<String>::
  #   The string from which the given condition was extracted.
  # cond<Array[Fixnum, Fixnum, Fixnum, Fixnum]>::
  #   An array containing the start and stop-positions of the condition and
  #   it's if, then and else-clauses in the string.
  def then_clause(string, cond)
    string[cond[1] + 1, cond[2] - cond[1]] || ''
  end

  # Returns the else-clause of the given condition in the given string.
  #
  # ==== Parameters
  # string<String>::
  #   The string from which the given condition was extracted.
  # cond<Array[Fixnum, Fixnum, Fixnum, Fixnum]>::
  #   An array containing the start and stop-positions of the condition and
  #   it's if, then and else-clauses in the string.
  def else_clause(string, cond)
    string[cond[2] + 1, cond[3] - cond[2]] || ''
  end
end
