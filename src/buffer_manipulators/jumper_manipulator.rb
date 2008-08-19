require File.dirname(__FILE__) + '/../string_inserter'
require File.dirname(__FILE__) + '/../matcher'

String.send(:include, GeditSnippetMatcher)

class JumperManipulator   
	attr_accessor :window, :buffer
  def initialize(window=nil, buffer=nil)
  	@window = window
    @buffer = buffer
    monkey_patch_buffer!
  end

  def buffer=(buf)
    @buffer = buf
    monkey_patch_buffer!
    @buffer
  end

  # Jumps to the next tag in the buffer. If the tag is an extended tag, it'll
  # mark the contents of the tag with the cursor. 
  #
  # ==== Parameters
  # history<TagHistory>::
  #   A TagHistory-object which will be manipulated by this object.
  # ---
  # @public
  def manipulate!(history)
  	@history = history
    matches = buffer.buffer_lines.scan_filtered_snippets
    return cleanup if matches.size == 0
    handle_jump(matches)
    @history
  end

  private
  def handle_jump(matches)
    match       = first_match(matches)
    line_number = buffer.to_line_number(match)
    position_cursor(line_number, match.start_tag) 
    remove_mark(line_number, match)
    cleanup if buffer.buffer_lines.scan_filtered_snippets.size == 0
  end
  
  # This method sorts the matches after the tag-number and returns the first
  # element. If the tag has a zero, it should be the last element of the array.
  #
  # ==== Parameters
  # matches<String>::
  #   An array which contains tags, which are in the buffer-stream
  #
  # ==== Returns:
  # String::
  #   The first tag in the given array is returned.
  def first_match(matches)
    matches.sort_by do |a| 
      a.start_tag.index("${0") ? "${9999999999:" : a
    end.first
  end

  # Clears the history and returns the history-object
  #
  # ==== Returns
  # TagHistory:: 
  #   The TagHistory object is returned.
  def cleanup
    @history.clear
    @history
  end
  
  # Positions the cursor on the given line on the position of match.
  #
  # ==== Parameters
  # line<Fixnum>::
  #   Indicates the line number of the new cursor position.
  # match<String>::
  #   Is the first part of the string, which matched the buffer (e.g. ${1:)
  #   The position of this string will be searched in buffer, and the cursor
  #   will be positioned on the index of match in the buffer-line.
  def position_cursor(line, match)
    window.cursor = [ line, buffer[line].index(match) ]
  end

  # Removes the ${DIGIT: and }-tags from our extended and regular tags.
  # Moreover it returns some directions to vim to position the cursor
  # appropriately in the visual mode over our selection.
  # And it stores the inserted tag into the @last_edited-attribute. (see:
  # previous_not_edited?)
  #
  # ==== Parameters
  # line_number<Fixnum>::
  #   The start-line-number in which the given mark matches the buffer.
  # mark<String>::
  #   The snippet-tag which matched (e.g. ${1: something })
  def remove_mark(line_number, mark)
    inserter     = Inserter.new(line_number, mark, buffer)
    mark         = inserter.remove_tags_from_buffer!
    directions   = inserter.key_directions
    @history.last_tag    = mark
    @history.start_pos   = inserter.start_pos
    @history.line_number = line_number
    make_result(directions)
  end

  # This talks to vim and returns some results to it, so that the 
  # cursor position actually moves. 
  #
  # ==== Parameters
  # directions<String>::
  #   A string with a list of directions the cursor should walk in visual
  #   mode.
  def make_result(directions)
    if @history.last_tag.single_tag?
      Vim::command("let result = \"VIM_HACK_NOTHING\"") # HACK
      return
    end
    if @history.start_pos == 0 # we are at the leftmost position in the buffer
      Vim::command(
        "let result = \"\\<Esc>\\v#{directions}\\o\\<c-g>\""
      ) 
      return
    end
    Vim::command(
      "let result = \"\\<Esc>\\<Right>v#{directions}\\o\\<c-g>\""
    ) 
  end
  
  # Monkeypatches the BufferUtil module into the buffer-object unless it's
  # already patched in.
  def monkey_patch_buffer!
    unless @buffer.respond_to? :buffer
      @buffer.class.send(:include, BufferUtil) 
    end
  end
end
