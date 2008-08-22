# This class inserts the mark on the given line number in the buffer.
class Inserter
  attr_accessor :line_number, :mark, :buffer, :start_pos, :end_pos
  # initializes the Inserter.
  #
  # ==== Parameters
  # line_number<Fixnum>::
  #   The line number in the buffer where the mark matched.
  # mark<String>::
  #   The mark which matched.
  # buffer<Vim::Buffer>::
  #   The VI-Buffer, whose lines should be used for extracting the string.
  # ---
  # @public
  def initialize(line_number, mark, buffer)
    @line_number = line_number
    @mark        = mark
    @buffer      = buffer
  end

  # Returns some directions, which the cursor must walk to get to the 
  # end of the selection.
  #
  # ==== Returns
  # String::
  #   A String is returned, containing the directions which the cursor must
  #   walk in insert mode to get to the end of the insertion.
  # ---
  # @public
  def key_directions
    vertical   = start_line - end_line
    horizontal = calculate_horizontal(vertical)
    # some vodoo magic here. TODO explain this
    move_vertical(vertical) + 
    move_horizontal(horizontal)
  end

  # Returns the start position (column of the tag)
  # 
  # ==== Returns
  # Integer::
  #   The start column of the tag is returned
  # ---
  # @public
  def start_pos
    @start_pos ||= line.index(start_tag)
  end

  # Returns the end-position of the tag.
  #
  # ==== Returns
  # Integer: 
  #   The end-position of the tag is returned.
  # ---
  # @public
  def end_pos
    @end_pos ||= find_end_pos 
  end

  # Returns the start line of the insertion
  #
  # ==== Returns
  # Integer:
  #   The start-position of the tag is returned.
  # ---
  # @public
  def start_line
    @line_number
  end

  # Returns the end line of the tag in the current buffer
  #
  # ==== Returns
  # Integer:
  #   The end-line-position of the tag is returned.
  # ---
  # @public
  def end_line
    @end_line ||= find_end_line
  end

  # Removes the tags from the buffer by modifying it. This also handles tags
  # which span multiple lines.
  # YOU SHOULDN'T USE THIS OBJECT AGAIN AFTER MODIFYING IT, SINCE IF YOU ARE
  # DELETING THE TAGS FROM THE BUFFER, THERE IS NO WAY THAT START_LINE,
  # END_LINE, START_POS, ... MAKE SENSE!!!11!!
  #
  # ==== Returns
  # String:
  #   The new formattet mark is returned, since it'll be formattet
  #   with the CommandFormatter, if there are some placeholders in a tag.
  #
  # ---
  # @public
  def remove_tags_from_buffer!
    # Cache before modification!
    buffer[start_line] = remove_tag_first_line + end_line_string
    delete_lines!
    create_new_mark!
    @buffer.insert_string(@mark.without_tags, [
      start_line, start_pos
    ])
    clear
    @mark
  end

  private

  # Clears the start_pos, end_pos and sets a global flag, which indicates
  # that the buffer was already modified. This has influence to the
  # key_directions-method, which now don't need to subtract the start_tag-size
  # from the position.
  def clear
    @end_line = find_final_end_line
    @end_pos  = find_final_end_pos
    @tags_removed = true
  end

  # Removes the lines between end_line and start_line. It also removes
  # the end_line. The remaining contents of end_line must therefore 
  # be appended to the start_line before calling this method!
  def delete_lines!
    (end_line - start_line).times { |i| buffer.delete(start_line + 1) }
  end

  # Creates the new mark via the command formatter. The contents of the 
  # mark will be replaced with the result of the command formatter.
  #
  # ==== Returns
  # String:: 
  #   The new mark will be returned, but it will also be already modified 
  #   via this method.
  def create_new_mark!
    tag = @mark.start_tag
    @mark = tag + CommandFormatter.new(@mark.without_tags).format + 
      SnipFu::Config[:end_tag]
  end

  # Returns the remaining string at end_line if there is a string left after
  # the closing tag.
  #
  # ==== Returns
  # String::
  #   A string with the remaining part of the last_line will be returned.
  #   The string should be appended to the first line.
  def end_line_string
    line_end = ""
    if end_line != start_line
      line_end   = buffer[end_line]
      line_end[0, end_pos + 1] = ''
    end
    line_end
  end

  # Removes the tag in the first line and returns the string before the
  # opening tag.
  #
  # ==== Returns
  # String::
  #   The part of the first_line before the opening tag is returned.
  def remove_tag_first_line
    if start_line == end_line
      line[start_pos, end_pos - start_pos + 1] = ""
    else
      line[start_pos, line.size] = ""
    end
    line
  end

  # Returns the selected line from the buffer
  #
  # ==== Returns
  # String::
  #   A String representing the current line is returned.
  def line
    @line ||= @buffer[@line_number].dup
  end

  # Returns the starting tag of the mark
  #
  # ==== Returns
  # String:: 
  #   A string is returned, which includes the start-tag (open-tag) of the
  #   mark-tag of the object.
  #
  # ==== Example
  # # in: Inserter<mark="${52:some string}>
  # start_tag
  # # => "${52:"
  def start_tag
    mark.start_tag
  end

  # Helper method for #end_line. 
  def find_end_line
    find_line { @mark.length + buffer[start_line].index(@mark.start_tag) } 
  end

  def find_final_end_line
    find_line { @mark.length - @mark.start_tag.size - 1 + start_pos }
  end

  def find_final_end_pos
    find_pos { start_pos + mark.length - 2 - mark.start_tag.size }
  end

  def find_pos
    total_pos = yield
    return total_pos if start_line == end_line
    (start_line...end_line).inject(total_pos) do |length, i|
      length - buffer[i].length - 1
    end 
  end

  def find_line
    start  = start_line
    length = yield
    while buffer[start].length < length
      length -= (buffer[start].length + 1)    # don't forget the \n
      start += 1
    end
    start
  end

  # Helper method for #end_pos.
  def find_end_pos
    find_pos { start_pos + mark.length - 1 }
  end
  
  # Returns a string for moving vertical.
  #
  # ==== Parameters
  # times<Fixnum>:: The number of times the cursor should be moved vertical
  #
  # ==== Returns
  # String:: 
  #   A string is returned representing the number of times the VI-cursor must
  #   be moved vertical in order to reach the end of the tag.
  def move_vertical(times)
    dir = times < 0 ? '\<Down>' : '\<Up>'
    (1..times.abs).map { |i| dir }.join('')
  end

  # Returns a string for moving horizontal.
  #
  # ==== Parameters
  # times<Fixnum>:: The number of times the cursor should be moved horizontal
  #
  # ==== Returns
  # String:: 
  #   A string is returned representing the number of times the VI-cursor must
  #   be moved horizontal in order to reach the end of the tag.
  def move_horizontal(times)
    dir = times < 0 ? '\<Right>' : '\<Left>'
    times -= 1 if times > 0
    (1..times.abs).map { |i| dir }.join('')
  end


  # Calculates the horizontal directions
  #
  # ==== Parameters
  # vertical<Fixnum>::
  #   The number of times the curser is either moved up or down
  # 
  # ==== Returns
  # Fixnum:: 
  #   The number of times the cursor must be moved left or right.
  def calculate_horizontal(vertical)
    return buffer[end_line].length - end_pos + 1 if line_too_small?
    return start_pos - end_pos if @tags_removed
    (start_pos)  - (end_pos - subtract(vertical))
  end

  # Returns true if the end-line of the buffer is smaller then the
  # start-position. We must thus, use another algorithm to move the cursor
  # to the appropriate end-position.
  #
  # ==== Returns
  # Boolean::
  #   True if the line is too small
  def line_too_small?
    start_pos > buffer[end_line].length
  end

  # Returns the value, which should be subtracted from end_pos. If the end_pos
  # is in the same-line as the start_pos (vertical == 0), we must add the
  # length of the start-tag to the value to subtract. Otherwise it's enought to
  # subtract the lenght of the closing-tag (1)
  #
  # ==== Parameters
  # vertical<Fixnum>::
  #   The number of times the curser is either moved up or down
  #
  # ==== Returns
  # Fixnum::
  #   A number which should be subtracted from end_pos in order to 
  #   find the correct horizontal length.
  def subtract(vertical)
    return 1 + start_tag.length if vertical == 0
    1
  end
end
