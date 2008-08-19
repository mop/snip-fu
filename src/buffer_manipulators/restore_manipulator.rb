require File.dirname(__FILE__) + '/../string_inserter'

# This class is responsible for restoring the buffer if it wasn't edited by the
# user. The VI-editor actually deletes our insertion after pressing <Tab> if
# the cursor is placed on a placeholder. Thus we must restore it if the user
# wants to keep the default value.
class RestoreManipulator
  attr_accessor :window, :buffer
  # Initializes the manipulator with a given window and a given buffer.
  #
  # ==== Parameters
  # window<Vim::Window>::
  #   The Vim-Window
  # buffer<Vim::Buffer>::
  #   The Vim-Buffer
  # ---
  # @public
  def initialize(window=nil, buffer=nil)
    @window = window
    @buffer = buffer
  end

  # Manipulates the buffer with the given history object
  #
  # ==== Parameters
  # history<TagHistory>::
  #   The TagHistory object. The was_restored-flag will be actually set by this
  #   method if a tag was successfully restored!
  # ---
  # @public
  def manipulate!(history)
    @history = history
    return if previous_edited?
    do_manipulate
  end

  private
  def previous_edited?
    @history.last_tag.without_tags == "" || !same_cursor_position?
  end

  def same_cursor_position?
    window.cursor[1] == @history.start_pos && 
    window.cursor[0] == @history.line_number
  end

  def do_manipulate
    StringInserter.new(
      @buffer, @history.last_tag.without_tags, @window.cursor
    ).insert_string
    @history.was_restored = true
  end
end
