require File.dirname(__FILE__) + '/regexp_handler'

# This class replaces the contents of a command according to several patterns
# and enables to e.g. insert the selected text, ... into the command
# ---
# @public
class CommandFormatter
  # Initializes the formatter with the given string
  #
  # ==== Parameter
  # str<String>::
  #   The string which should be formatted. (e.g. ${VAR:default})
  def initialize(str)
    @string = str
  end

  # Yields each nested tag and reduces the result
  #
  # ==== Yields
  # Array[String, String]::
  #   The whole string is yielded as first parameter and the snippet 
  #   as second parameter. The result of the yield-block should be the
  #   new modified string. 
  def reduce_nested_tag
    str = @string
    while str.scan_snippets.any? { |snip| extended?(snip) }
      str = str.scan_snippets.inject(str) do |s, snip|
        yield s, snip
      end
    end
    str
  end

  # This method formats the snippet
  # TODO: Refactor this
  #
  # ==== Returns
  # String:: The formatted string is returned.
  def format
    # first of all, handle extended tags
    strs = reduce_nested_tag do |str, snip|
      start = str.index(snip)
      sub   = str[start, snip.size]
      str[start, snip.size] = sub.gsub(extended_regex) do |variable|
        variable = variable[1, variable.size] # remove $
        dispatch(variable)
      end
      str
    end
    
    strs.gsub(variable_regex) do |variable|
      variable = variable[1, variable.size] # remove $
      dispatch(variable)
    end.gsub(shell_regex) do |variable|
      dispatch(variable)
    end
  end


  private
  
  # Dispatches the given variable depending on it's classification
  #
  # ==== Parameters
  # variable<String>:: 
  #   The expression, which should be dispatched. e.g. $VAR or ${VAR:default}
  def dispatch(variable)
    case classify(variable)
    when :shell_command
      handle_shell(variable)
    when :extended
      handle_extended(variable)
    when :vim
      replace_vim_variable(variable)
    when :env
      ENV[variable]
    end
  end

  # Handles an "extended" variable. Extended variables are variables like
  # ${VAR:default} or ${VAR/regexp/format/opts}
  #
  # ==== Parameter
  # variable<String>:: The string which should be transformed.
  #
  # ==== Returns
  # String:: 
  #   The translated string is returned.
  def handle_extended(variable)
    return handle_regexp(variable) if regexp?(variable)
    return handle_replace(variable)
  end

  # Handles an extended regular expression tag. A extended regexp tag looks
  # like ${VAR/<regexp>/<format>/<opts}.
  #
  # ==== Parameters
  # str<String>::
  #   The regexp-tag
  # 
  # ==== Returns
  # String::
  #   A translated string is returned.
  def handle_regexp(str)
    str  = str[1, str.size - 2]   # remove the outer {}
    stop = str.index('/')         
    txt  = dispatch(str[0, stop]) # dispatch the variable to find the real val.
    txt ||= str[0, stop]  # if we got nil, we are using the prev. txt
    str[0, stop] = txt
    RegexpHandler.new(str).replace  # replace with regexp
  end

  # Handles an extended default expression tag. A extended default tag looks
  # like ${VAR:default}.
  #
  # ==== Parameters
  # str<String>::
  #   The regexp-tag
  # 
  # ==== Returns
  # String::
  #   A translated string is returned.
  def handle_replace(variable)
    variable = variable[1, variable.size - 2]
    array    = variable.split(":")
    var      = array[0]
    default  = array[1, array.size].join(':')
    result   = dispatch(var)
    result == "" || result.nil? ? default : result
  end

  # Classifies the given variable and returns the type of the variable.
  #
  # ==== Parameters
  # variable<String>:: 
  #   The variable which should be classified (e.g. $VAR, ${VAR:default}, ..)
  #
  # ==== Returns
  # Symbol::
  #   Either :shell_command, :extended, :vim or :env is returned.
  def classify(variable)
    return :shell_command if shell_command?(variable)
    return :extended      if extended?(variable)
    return :vim           if vim_mappings.has_key?(variable)
    return :env
  end

  # Handles the given shell-command by opening a pipe and writing it into 
  # it. The result of the command is actually strippet
  #
  # ==== Parameters
  # cmd<String>:: the shell-command
  #
  # ==== Returns
  # String:: the stdout result of the shell-command is returned.
  def handle_shell(cmd)
    cmd = cmd[1, cmd.size - 2]
    result = ""
    export_vim
    IO.popen("sh -s", 'w+') do |p|
      p.write cmd
      p.write "\nexit 0\n"      # make shure to end it
      result = p.read
    end
    result.strip
  end

  # Exports the VIM-variables as environment variables.
  def export_vim
    vim_mappings.keys.each do |mapping| 
      ENV[mapping] = replace_vim_variable(mapping)
    end
  end

  # Returns not nil if the given variable is a shell command
  #
  # ==== Parameters
  # variable<String>:: The variable, which should be checked
  #
  # ==== Returns
  # Fixnum:: not nil, if it's an shell command, otherwise nil.
  def shell_command?(variable)
    variable =~ /^`.*`$/m
  end

  # Returns not nil if the given variable is an extended command
  #
  # ==== Parameters
  # variable<String>:: The variable, which should be checked
  #
  # ==== Returns
  # Fixnum:: not nil, if it's an extended command, otherwise nil.
  def extended?(variable)
    variable =~ extended_regex
  end
  
  # Returns not nil if the given variable is a regexp command
  #
  # ==== Parameters
  # var<String>:: The variable, which should be checked
  #
  # ==== Returns
  # Fixnum:: not nil, if it's a regexp command, otherwise nil.
  def regexp?(var)
    return false unless extended?(var)
    colon = var.index(':') || var.size
    slash = var.index('/') || var.size
    slash < colon
  end

  # Returns the regular expression which should be used for searching 
  # for an extended variable.
  #
  # ==== Returns
  # Regexp:: The regular expression which should be used.
  def extended_regex
    /^
      \$?          # Every extended-tag starts with $
      (\{          # followed by { -> ${
      [^\d]        # it _must_not_ be followed by a single digit
      .+(:|\/).*?  # it must have a colon or a slash in it ${VAR1:default 
      \})          # it is closed by } -> ${VAR:default}
    $/xm
  end

  # Returns the regular expression which should be used for searching 
  # for a regular variable.
  #
  # ==== Returns
  # Regexp:: The regular expression which should be used.
  def variable_regex
    /
      \$            # start tag
      ([\w_]+)      # our variables are starting with $ and are followed by 
                    # upcase letters or _. We want to match the variable name
    /xm
  end

  # Returns the regular expression which should be used for searching 
  # for a shell command.
  #
  # ==== Returns
  # Regexp:: The regular expression which should be used.
  def shell_regex
    /
      (\`.+\`)
    /xm
  end

  # Replaces the given vim-variable with it's value
  #
  # ==== Parameters
  # variable<String>:: An variable, whose contents must be queried from vim
  #
  # ==== Returns
  # String:: The value of the variable is returned.
  def replace_vim_variable(variable)
    Vim::command("let snip_tmp = #{vim_mappings[variable]}")
    result = Vim::evaluate("snip_tmp")
    case variable
    when "VI_SOFT_TABS"
      result = (result == "1" ? "YES" : "NO")
    when "VI_FILENAME"
      result = File.basename(result)
    else
      result
    end
  end

  # Some mappings from vim-variables to vim-commands used for querying vim
  #
  # ==== Returns
  # Hash<String => String>:: a hash for the mappings is returned.
  def vim_mappings
    { 
      "VI_SELECTED_TEXT" => "getreg()",
      "VI_FILENAME"      => "@%",
      "VI_CURRENT_LINE"  => "getline(\".\")",
      "VI_SOFT_TABS"     => "&expandtab"
    }
  end
end
