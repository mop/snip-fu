require 'inserter'
require 'snippet'
require 'string_extractor'
require 'string_inserter'
require 'snippet_loader'
require 'mirrorer'
require 'buffer_util'

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

    @snippet_loader = SnippetLoader.new
    @snippet_loader.load_snippets
    monkey_patch_buffer!
  end

  # Monkeypatches the BufferUtil module into the buffer-object unless it's
  # already patched in.
  def monkey_patch_buffer!
    unless @buffer.respond_to? :buffer
      @buffer.class.send(:include, BufferUtil) 
    end
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
    @snippet_loader.current_snippets.each do |snippet|
      snippet.buffer = buf
    end
    monkey_patch_buffer!
    @buffer
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
    @snippet_loader.current_snippets.each do |snippet|
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
    restore_yank if @was_restored || last_insert != ""
    Mirrorer.new(buffer, @last_edited[0], last_insert).mirror_tags!
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
    matches = buffer.buffer_lines.scan_filtered_snippets
    return cleanup unless matches.size > 0
    
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

  # Cleans up all the bunch of hacks we don't need anymore, since there
  # are no tags anymore in the buffer.
  def cleanup
    @last_edited  = nil
    @was_restored = nil
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
    StringInserter.new(
      @buffer, previous_selection, @window.cursor
    ).insert_string
    @was_restored = true  # HACK
  end

  def restore_yank
    Vim.command("call setreg(v:register, \"#{@yank.gsub(/"/, '\"')}\")") if @yank
  end

  def save_yank
    @yank = Vim.evaluate("getreg()")
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
    mark         = inserter.remove_tags_from_buffer!
    directions   = inserter.key_directions
    @last_edited = [mark, inserter.start_pos, line_number]
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
    if @last_edited[0].single_tag?
      Vim::command("let result = \"VIM_HACK_NOTHING\"") # HACK
      return
    end
    save_yank
    if @last_edited[1] == 0 # we are at the leftmost position in the buffer
      Vim::command(
        "let result = \"\\<Esc>\\v#{directions}\\o\\<c-g>\""
      ) 
      return
    end
    Vim::command(
      "let result = \"\\<Esc>\\<Right>v#{directions}\\o\\<c-g>\""
    ) 
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
    snippet = @snippet_loader.current_snippets.find { |snip| snip.pressed? }
    if snippet
      snippet.insert_snippet
      @last_edited = nil
    end
  end
end

