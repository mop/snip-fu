# This module defines two helper methods for checking if the last inserted
# extended tag was edited by the user, or was left alone by the user
module EditedChecker
  # Returns true if the previous inserted extended tag was edited by the user
  #
  # ==== Returns
  # Bool::
  #   True if the tag was edited, or was no extended tag at all.
  def previous_edited?
    @history.last_tag.nil? || @history.last_tag.without_tags == "" || 
      !same_cursor_position?
  end

  # Returns true if the cursor position is the same as the start-position of
  # the last inserted tag.
  #
  # ==== Returns
  # Bool:: True if the both positions are the same
  def same_cursor_position?
    window.cursor[1] == @history.start_pos && 
    window.cursor[0] == @history.line_number
  end
end
