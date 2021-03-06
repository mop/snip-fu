require File.dirname(__FILE__) + '/condition_parser'
require 'rubygems'
require 'oniguruma'
# This class is responsible for replacing regular expressions
# It formats regexps according to the given pattern.
# ---
# @package
class RegexpHandler
  # Initializes the handle with the given expression
  #
  # ==== Parameters 
  # expr<String>::
  #   The replacement expression with the formant: 
  #   <text>/<regexp>/<format>/<opts>
  def initialize(expr)
    @expression = expr
  end

  # Evaluates the given expression and returns the substituted/transformed text
  #
  # ===== Returns
  # String::
  #   The translated text is returned.
  def replace
    re = Oniguruma::ORegexp.new(regexp, options)
    result = re.send(sub_method, text) do |match|
      fold_cases(replace_tags(apply_conditionals(match), match))
    end
    translate_special_chars(result)
  end

  private

  # Translates '\n' to "\n" and '\t' to "\t". Those strings might be escaped
  # through '\\\n' and '\\\t' which will be translated to '\n' and '\t'.
  #
  # ==== Parameters 
  # string<String>:: The string which should be translated
  #
  # ==== Returns
  # String:: The translated string is returned.
  def translate_special_chars(string)
    result = ""
    i = 0
    while i < string.size
      chunk, i = parse_chunk(string, i)
      result += chunk
    end
    result
  end

  # This method parses a chunk of the given string.
  #
  # ==== Parameters
  # string<String>:: The string which should be parsed for \t's and \n's.
  # i<Fixnum>:: The position in the string at which the parser currently is.
  #
  # ==== Returns
  # Array[String, i]:: 
  #   A tuple is returned with the chunk parsed an the new parser-position
  def parse_chunk(string, i)
    case string[i, string.size]
    when /^\\\\(t|n).*/
      [ string[i + 1, 2], i + 4 ]
    when /^\\(t|n).*/
      [(string[i, 2] == '\t') ? "\t" : "\n", i + 2 ]
    else
      [ string[i].chr, i + 1 ]
    end
  end


  # Returns the method for the given element.
  #
  # ==== Parameters
  # elem<String>::
  #   Either u, U, l or L
  #
  # ==== Returns
  # Symbol::
  #   The method on the stirng, which should be called for tranlations is
  #   returned.
  def method_for(elem)
    case elem
    when /(u|U)/
      :upcase
    when /(l|L)/
      :downcase
    end
  end

  # Returns the remaining upcase letters for the given element(s)
  #
  # ==== Parameters
  # elem<String|Array[String]>::
  #   A list of elements, or a single element which might be U, L or E.
  #
  # ==== Returns
  # Array[String]::
  #   A list of elements is returned which includes all available
  #   case-transformers except those in the given elem.
  def remaining_elements(elem)
    [ 'U', 'L', 'E' ] - [* elem ]
  end

  # Folds the cases (\u \U \l \L \E) for the given string.
  #
  # ==== Parameters
  # str<String>::
  #   The string, which should be translated.
  #
  # ==== Returns
  # String::
  #   A translated string is returned.
  def fold_cases(str)
    str = handle_single_chars(str)
    handle_multi_chars(str).gsub(/([^\\])(\\(u|U|l|L|E))/, '\1')
  end

  # Handles the transformers, which apply to a single char.
  #
  # ==== Parameters
  # str<String>::
  #   A string, which should be replaced.
  #
  # ==== Returns
  # String::
  #   The translated string is returned.
  def handle_single_chars(str)
    str = [ 'u', 'l' ].inject(str) do |str, elem|
      while pos = next_element(str, elem)
        next str unless pos
        str = modify_letter(str, pos + 2, method_for(elem))
      end
      str
    end
  end

  # Handles the transformers, which apply to a multiple chars.
  #
  # ==== Parameters
  # str<String>::
  #   A string, which should be replaced.
  #
  # ==== Returns
  # String::
  #   The translated string is returned.
  def handle_multi_chars(str)
    while (pos = next_element_result(str, 'U', 'L'))
      elem, start_pos = pos
      next_pos = next_element(
        str[start_pos, str.size],
        *remaining_elements(elem)
      ) - 2 rescue str.size - start_pos
      next_pos += start_pos
      str = modify_string(str, start_pos, next_pos, method_for(elem))
    end
    str
  end

  # This method is similar to #next_element, except that it returns an array
  # with the element, what matched as first element, and the position in the
  # given str as second parameter.
  #
  # ==== Parameters
  # str<String>:: The string, which should be searched.
  # *elems<String>:: The elements, for which the string should be searched
  #
  # ==== Returns
  # Array[String, Fixnum]:: 
  #   An tuple with the matched element and the position in the string is 
  #   returned.
  def next_element_result(str, *elems)
    pos = next_element(str, *elems)
    return nil unless pos
    [ str[pos + 1].chr, pos ]
  end

  # Modifies the given string at the given start <-> stop range by calling
  # the given method on the substring.
  #
  # ==== Parameters
  # str<String>:: The string, which should be modified
  # start<Fixnum>:: The start position of the string
  # stop<Fixnum>:: The end position of the string
  # method<Symbol>:: The method which should be called on the substring
  #
  # ==== Returns
  # String:: The modified string is returned.
  def modify_string(str, start, stop, method)
    start += 2      # modify the positions because of \L, \U, ..
    stop  += 2
    str[start, stop - start] = str[start, stop - start].send(method)
    str[start - 2, 2] = ''  # Delete the old mark
    str
  end

  # Returns the position of the element in the given string. 
  # If multiple elements are given the nearest will be returned.
  #
  # ==== Parameters
  # str<String>:: The string which should be searched
  # elems<Array[String]>:: 
  # The list of elements which should be found in str
  #
  # ==== Returns
  # Fixnum:: The position of the element, or nil
  def next_element(str, *elems)
    pos = elems.inject(str.size) do |pos, elem|
      new_pos = str =~ /\\#{elem}/
      next pos unless new_pos
      new_pos < pos ? new_pos : pos
    end
    pos == str.size ? nil : pos
  end

  # Modifies a letter in the given str on the given position using the given 
  # method.
  #
  # ==== Parameters
  # str<String>:: The string which should be modified
  # pos<Fixnum>:: The position on which the element was found
  # method<Symbol:: The method with which the element should be modified.
  #
  # ==== Returns
  # String:: The translated string is returned.
  def modify_letter(str, pos, method)
    str[pos] = str[pos].chr.send(method)
    str[pos - 2, 2] = ''    # remove mark
    str
  end

  # Replaces the \0, \1, ... tags with the matched value
  #
  # ==== Parameters
  # string<String>:: 
  #   The string which contains the \0, \1, ... tags
  # tags<MatchData>::
  #   The tags, which contain the corresponding tags
  def replace_tags(string, tags)
    string.gsub(/\\(\d+)/) do |match|
      pos = match[1, match.size].to_i
      tags[pos]
    end
  end

  # Applies the conditionals to the given matched tags
  #
  # ==== Parameters
  # match<MatchData>::
  #   The match-data, which contains the matched subgroups in the regexp
  #
  # ==== Returns
  # String::
  #   The evaluated condition expression will be returned. This expression must
  #   still be fold-translated and tag-replaced.
  def apply_conditionals(match)
    cond = replace_conditionals(match)
    re = Oniguruma::ORegexp.new(regexp, options)
    ConditionParser.new(cond).evaluate
  end

  # Replaces the format with the given match-data
  #
  # ==== Parameters
  # match<MatchData>::
  #   The match-data, which contains the matched subgroups in the regexp
  #
  # ==== Returns
  # String::
  #   The evaluated condition expression will be returned. This expression must
  #   still be fold-translated and tag-replaced.
  def replace_conditionals(match)
    match = match[0] if match.kind_of? Array
    format.gsub(/[^\\]?\?\d/) do |m| # search for ?1, ?2, ?... expressions
      str = match[m[-1].chr.to_i] ? "MATCH" : '' # m[-1] = 1, or 2, ...
      "#{m[0, 2]}#{str}"    # return (?MATCH or (?
    end
  end

  # Returns the text part of the expression
  #
  # ==== Returns
  # String:: The text-part of the expression is returned.
  def text
    @expression[0, @expression.index('/')]
  end

  # Returns the expression part of the expression
  #
  # ==== Returns
  # String:: The expression-part of the expression is returned.
  def expr
    @expression[@expression.index('/'), @expression.size]
  end

  # Returns the regexp part of the expression
  #
  # ==== Returns
  # String:: The regexp-part of the expression is returned.
  def regexp
    @regexp ||= expr.match(regexp_for_expression)[1]
  end

  # Returns the options-part of the translation-expression
  #
  # ==== Returns
  # String::
  #   The options of the given translation-expressions are returned 
  #   (a string including one or more of the following characters: imxog)
  #   If no options-part is existing, "" is returned.
  def options
  	@options ||= (expr.match(regexp_for_expression)[3]).gsub('g', '')
  end

  # Returns the sub-method, which should be used for the regular expression. 
  # 
  # ==== Returns
  # String::
  #   'gsub' is returned if the options include a 'g', otherwise 'sub' is
  #   returned.
  def sub_method
  	expr.match(regexp_for_expression)[3].include?('g') ? 'gsub' : 'sub'
  end

  # Returns the match-method, which should be used for the regular expression. 
  # 
  # ==== Returns
  # String::
  #   'scan' is returned if the options include a 'g', otherwise 'match' is
  #   returned.
  def match_method
  	expr.match(regexp_for_expression)[3].include?('g') ? 'scan' : 'match'
  end

  # Returns the format part of the expression
  #
  # ==== Returns
  # String:: The format-part of the expression is returned.
  def format
    @format ||= transform_placeholders(expr.match(regexp_for_expression)[2])
  end

  # Transforms the placeholders from $0 $1 to \0 \1
  #
  # ==== Parameters
  # str<String>:: The format-string which should be substituded.
  #
  # ==== Returns
  # String:: The substituted placeholders are returned.
  def transform_placeholders(str)
    str.gsub(/(\$\d|\$\{\d\})/) do |match|
      tmp = match[1, match.size]
      tmp = tmp[1].chr if tmp.size > 1
      "\\#{tmp}"
    end
  end

  # Returns the regular expression used for matching.
  #
  # ==== Returns
  # Regexp:: A regular expression is returned.
  def regexp_for_expression
    @regexp_for_expression ||= %r{
      [^\\]?/         # The beginning consists of the first unescaped '/'
      (.*[^\\])       # Now we want to match the whole text until the next
                      # '/'. We are allowing '\' to escape '/' in the text. 
                      # thus there shouldn't be a '\' before the middle '/'.
      /               # The central slash: /some\/text/
      (.*[^\\])       # Just the same as above: /some\/text\/some\/text
      /               # the final slash, we are nearly done!
      ([imxog]*)      # some optional options
    }xm
  end
end
