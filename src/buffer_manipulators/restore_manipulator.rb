require File.dirname(__FILE__) + '/manipulator_helper'
require File.dirname(__FILE__) + '/../edited_checker'

# This class is responsible for restoring the buffer if it wasn't edited by the
# user. The VI-editor actually deletes our insertion after pressing <Tab> if
# the cursor is placed on a placeholder. Thus we must restore it if the user
# wants to keep the default value.
class RestoreManipulator
  include ManipulatorHelper
  include EditedChecker

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
    return @history if previous_edited?
    do_manipulate
    @history
  end

  private
  def previous_edited?
    @history.last_tag.nil? || @history.last_tag.without_tags == "" || 
      !same_cursor_position?
  end

  def same_cursor_position?
    window.cursor[1] == @history.start_pos && 
    window.cursor[0] == @history.line_number
  end

  def do_manipulate
    @buffer.insert_string(@history.last_tag.without_tags, @window.cursor)
    @history.was_restored = true
  end
end
