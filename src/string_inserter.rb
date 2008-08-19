# Inserts a string into the given buffer on the given position
class StringInserter
  attr_accessor :buffer, :string, :position, :start_line, :start_pos
  # Initializes the inserter with a buffer, a string to insert and a 
  # start position.
  #
  # ==== Parameters
  # buffer<Vim::Buffer>::
  #   The VI-Buffer into which the string should be inserted
  # string<String>::
  #   The string which should be inserted into the buffer
  # pos<Array[Fixnum, Fixnum]>::
  #   The position into which she string should be inserted: (line, col)
  # ---
  # @public
  def initialize(buffer, string, pos)
    @buffer   = buffer
    @string   = string
    @position = pos

    @start_line = pos[0]
    @start_pos  = pos[1]
  end

  # Inserts the string into the buffer
  # ---
  # @public
  def insert_string
    return if string == ""
    disable_indent
    to_append = first_line_rest
    buffer[start_line] = first_line

    each_line_between do |line, idx|
      line = "#{line}#{to_append}" if idx == 0
      buffer.append(start_line, line)
    end
    enable_indent
  end

  private
  # Disables the indentation of vim
  def disable_indent
  	@filetype = Vim.evaluate("&filetype")
    Vim.command("set indentexpr=\"\"")
    Vim.command("set indentkeys=\"\"")
    Vim.command("unlet b:did_indent")
  end

  # Enables the indentation of vim
  def enable_indent
  	Vim.command("set filetype=#{@filetype}")
  end

  # Returns the string splitted by \n as array
  #
  # ==== Returns
  # Array<String>::
  #   An array of lines is returned
  def lines 
    string.split("\n")
  end

  # Returns true if the string, which should be inserted is a multiline-string
  #
  # ==== Returns
  # Bool::
  #   True if the string spans over multiple lines, otherwise false.
  def multiline?
    lines.size > 1
  end

  # Yields each line from the second line until the end with an index in the
  # reverse order.
  def each_line_between
    lines[1..lines.size].reverse.each_with_index do |l, i|
      yield l, i
    end
  end

  # Extends the given string, so that the start_position can be easily accessed
  # without raising an error.
  #
  # ==== Parameters
  # str<String>::
  #   The string which should be extended.
  #
  # ==== Returns
  # String::
  #   A new, extended string is returned.
  def extend_start(str)
    while start_pos >= str.size
      str += " "
    end
    str
  end

  # Returns the new replaced first line of the buffer. If we are having a
  # multiline-string, the string in the first line after the insertion-position
  # must be appended at the end of our insertion.
  # If we are having a single-line string, we can insert the string simply into
  # the buffer.
  #
  # ==== Returns
  # String::
  #   The replaced first line is returned, which must be assigned to the
  #   buffer.
  def first_line
    str = buffer[start_line]
    if multiline?
      str[start_pos, str.size]  = lines.first
    else
      if must_extend?(str)
        str = extend_start(str)
        str[start_pos] = lines.first
      else
        str.insert(start_pos, lines.first)
      end
    end
    str
  end

  # Returns true if the string must be extended because otherwise an exception
  # would be thrown.
  #
  # ==== Parameters
  # str<String>::
  #   The string, which should be checked.
  #
  # ==== Returns
  # Bool::
  #   True if it must be extended
  def must_extend?(str)
    start_pos >= str.size
  end

  # Returns the part in the first line, which will be overwritten and thus 
  # must be appended to our string if we have a multiline-string.
  #
  # ==== Returns
  # String::
  #   Returns the rest of the first line as String
  def first_line_rest
    line = buffer[start_line]
    line[start_pos, line.size]
  end
end
