require 'inserter'
require 'snippet'
require 'string_extractor'
require 'string_inserter'

String.send(:include, GeditSnippetMatcher)

# This class responsible for managing the buffer with Snippets, Inserters.
# It is able to determine whether or not a current snippet should be inserted
# and is able to jump to the next snippet in the buffer.
class BufferManager
  attr_accessor :snippets, :buffer, :window

  # Initializes the Manager
  #
  # ==== Parameters 
  # window<Vim::Window>::
  #   The VIM-Window, used to get the position of the cursor
  # buffer<Vim::Buffer>::
  #   The VIM-Buffer, used to find/insert snippets
  def initialize(window=VIM::Window.current, buffer=VIM::Buffer.current)
    @window = window
    @buffer = buffer

    @snippets ||= [
      Snippet.new(
        "for",
        "for ${0:key} in ${1:vals}\n${2}\nend\n${3}",
        @window, @buffer
      ),
      Snippet.new(
        "send_mail",
        "send_mail(${1:${2:Some}Mailer}, :${3:mailer_action}${5:, {
	:from =&gt; ${10:'${11:from@acme.com}'}, 
	:to =&gt; ${12:'${13:some@user.com}'},
	:subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }}})",
        @window, @buffer
      ),
      Snippet.new(
        "aftp",
        "after Proc.new { |c| ${1:c.some_method} }${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}",
        @window, @buffer
      ),
      Snippet.new(
        "test",
        "test ${1:value} something ${1}", @window, @buffer
      )
    ]
  end

  # Updates the buffer of the manager and of each of it's snippets with the 
  # given buffer.
  #
  # ==== Parameters
  # buf<Vim::Buffer>::
  #   The new, updated VI-Buffer
  # ---
  # @public
  def buffer=(buf)
    @buffer = buf
    @snippets.each do |snippet|
      snippet.buffer = buf
    end
  end

  # Updates the window of the manager and of each of it's snippets with the 
  # given window.
  #
  # ==== Parameters
  # win<Vim::Window>::
  #   The new, updated VI-Window
  # ---
  # @public
  def window=(win)
    @window = win
    @snippets.each do |snippet|
      snippet.window = win 
    end
  end

  # Renames other tags, which have the same mark as the last one with the 
  # contents of the last node. Only regular tags will be renamed, not
  # extended tags.
  #
  # ==== Notes
  # This method modifies the buffer.
  def rename_other
    digit = @last_edited[0].digit_tag
    digit_str = "${#{digit}}"
    while buffers_lines =~ /\$\{#{digit}\}/m
      line_number = to_line_number(digit_str)
      line = buffer[line_number]
      to_insert = last_insert
      idx = line.index(digit_str)
      buffer[line_number] = line.sub(digit_str, "")
      StringInserter.new(buffer, to_insert, [line_number, idx]).insert_string
    end
  end

  # This method returns the string the user has inserted
  def last_insert
    if @was_restored
      @was_restored = nil
      return previous_selection
    end
    prev_pos, prev_line = @last_edited[1, 2]
    line, pos           = window.cursor
    StringExtractor.new(
      buffer, [prev_line, prev_pos], [line, pos]
    ).extract_string
  end

  # Jumps to the next tag in the buffer. If the tag is an extended tag, it'll
  # mark the contents of the tag with the cursor. 
  # ---
  # @public
  def jump
    restore_previous if previous_not_edited?
    rename_other     if previous_selection
    matches = buffers_lines.scan_snippets
    return cleanup unless matches.size > 0
    
    match = matches.sort.first
    line_number = to_line_number(match)
    position_cursor(line_number, match.start_tag) 
    remove_mark(line_number, match)
    cleanup if buffers_lines.scan_snippets.size == 0
  end

  # Cleans up all the bunch of hacks we don't need anymore, since there
  # are no tags anymore in the buffer.
  def cleanup
    @last_edited  = nil
    @was_restored = nil
  end

  # Converts the given match to the start-line-number in the Vi-buffer.
  # 
  # ==== Parameters
  # match<String>::
  #   Is a string which contains a matched tag e.g.: ${1:a tag}
  #
  # ==== Returns
  # Fixnum::
  #   Indicates the start-line of the expression in the buffer stream
  #
  # ==== Example
  #   # Buffer-stream contains "some\nlines with ${1:a\ntag}"
  #   # Buffer-array contains ["some", "lines", "with", "${1:a", "tag}"]
  #   #                          /\       /\      /\        /\     /\
  #   # Positions:               1        2       3         4      5
  #   to_line_number("${1:a\ntag}")
  #   # => 4
  def to_line_number(match)
    idx = buffers_lines.index(match)
    buffer_line_cycle.each do |line_number|
      idx -= buffer[line_number].size
      break line_number if idx <= 0
    end
  end

  # Restores the previous typed word, which wasn't modified by the user. This
  # happens if a user has an extended tab, and doesn't changes the 
  # preselection. If he now presses <TAB> again, VIM will actually remove
  # the word from the buffer :(. Hence we must insert it again, which is
  # actually very painful :/.
  # The original word (including it's original position) is restored from the 
  # @last_edited-attribute
  #
  # ==== Notes
  # This method modifies the buffer!
  def restore_previous
    return unless @last_edited
    Snippet.new('', previous_selection).insert_snippet
    @was_restored = true  # HACK
  end

  # Returns the previous selected word in an extended-tag. If the previous tag
  # was a regular tag "" is returned. If no tag was previously pressed, nil is
  # returned.
  #
  # ==== Returns
  # (String | nil)::
  #   The previous word is returned. If no predecessor is existing, nil is
  #   returned.
  def previous_selection
    return nil unless @last_edited
    @last_edited[0].without_tags
  end

  def log
    File.open("/home/nax/vimdebug.txt", "a") do |f|
      yield f
    end
  end

  # Returns true if the cursor-position hasn't changed and thus nothing has 
  # been inserted. Because VIM deletes everytime our selection, even though we
  # aren't modifying it, we must insert it again.
  #
  # ==== Returns
  # Bool::
  #   True if we should insert our last word again, and false if we shouldn't
  #   touch it again.
  def buffer_matches?
    window.cursor[1] == @last_edited[1] &&  # pos
    window.cursor[0] == @last_edited[2]     # line
  end

  # Returns true if the previous inserted word wasn't modified. 
  #
  # ==== Returns
  # Bool::
  #   True if we should insert our last word again, and false if we shouldn't
  #   touch it again. 
  def previous_not_edited?
    previous_selection && previous_selection != "" &&
      buffer_matches?
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
    no_tags      = inserter.remove_tags_from_buffer!
    directions   = inserter.key_directions
    make_result(directions)
    @last_edited = [mark, inserter.start_pos, line_number]
  end

  # This talks to vim and returns some results to it, so that the 
  # cursor position actually moves. 
  #
  # ==== Parameters
  # directions<String>::
  #   A string with a list of directions the cursor should walk in visual
  #   mode.
  def make_result(directions)
    if directions.size > 0
      Vim::command(
        "let result = \"\\<Esc>\\<Right>v#{directions}\\o\\<c-g>\""
      ) 
    else
      Vim::command("let result = \"VIM_HACK_NOTHING\"") # HACK
    end
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

  # Handles the insertion of new snippets. If the last word in the buffer
  # matches any snippet, the snippet will be inserted in the buffer.
  # ---
  # @public
  def handle_insert
    snippet = @snippets.find { |snip| snip.pressed? }
    snippet.insert_snippet rescue nil
  end

  # Returns the buffer-lines beginning at the current line number, until the
  # end and from the beginning to the current line number.
  # If we are e.g. on line number 3 and the buffer has e.g. 5 lines the
  # following line-numbers are returned [3, 4, 5, 1, 2].
  #
  # ==== Returns
  # Array[Fixnum]::
  #   A list of line-number is returned.
  def buffer_line_cycle
    ((buffer.line_number..buffer.count).to_a + 
    (1..buffer.line_number).to_a).uniq
  end

  # Maps the buffer_line_cycle-array to it's corresponding lines and joins them
  # with "\n", so that a buffer stream is basically returned, starting on the
  # current line position.
  #
  # ==== Returns 
  # String::
  #   The lines in the buffer are returned as a string-stream
  def buffers_lines
    buffer_line_cycle.map { |i| buffer[i] }.join("\n")
  end
end

