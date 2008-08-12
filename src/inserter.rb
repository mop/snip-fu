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

  # This function removes the tags form the first line of the buffer. 
  # It returns the removed line and the buffer must be updated manually
  # 
  # ==== Returns
  # String::
  #   The selected line without the matched tag, which should be used to 
  #   updated the buffer.
  # ---
  # @public
  def remove_tags_from_line
    line[end_pos] = "" if start_line == end_line     # Remove the end
    line[start_pos, start_tag.length] = ""           # Remove the start
    line
  end

  # Yields the number of elements of the mark without tags.
  # ---
  # @public
  def map_elements
    (0...(mark.length - start_tag.length - 2)).map { |i| yield i }
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
    # some vodoo magic here. TODO explain this
    subtract = 1
    subtract += start_tag.length if vertical == 0
    horizontal = (start_pos)  - (end_pos - subtract)
    move_vertical(vertical) + 
    move_horizontal(horizontal)
  end
  
  def move_vertical(times)
    dir = times < 0 ? '\<Down>' : '\<Up>'
    (1..times.abs).map { |i| dir }.join('')
  end

  def move_horizontal(times)
    dir = times < 0 ? '\<Right>' : '\<Left>'
    times -= 1 if times > 0
    (1..times.abs).map { |i| dir }.join('')
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
  # ---
  # @public
  def remove_tags_from_buffer!
    # Cache before modification!
    el = end_line
    ep = end_pos
    buffer[start_line] = remove_tags_from_line
    return if start_line == end_line

    line_end     = buffer[el]
    line_end[ep] = ''
    buffer[el]   = line_end
  end

  private
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
    start  = start_line
    length = @mark.length
    while buffer[start].length < length
      length -= buffer[start].length
      start += 1
    end
    start
  end

  # Helper method for #end_pos.
  def find_end_pos
    total_pos = start_pos + mark.length - 1
    if start_line == end_line
      return total_pos
    end
    (start_line...end_line).inject(total_pos) do |length, i|
      length - buffer[i].length - 1
    end 
  end
end
