require File.dirname(__FILE__) + '/manipulator_helper'

class MirrorManipulator
  include ManipulatorHelper

  # Manipulates the buffer with the given history object.
  #
  # ==== Parameters
  # history<TagHistory>::
  #   A TagHistory-object whose information will be used to mirror the tags
  def manipulate!(history)
  	@history = history
    return @history unless @history.last_tag
    Mirrorer.new(buffer, history.last_tag, last_insert).mirror_tags!
    @history
  end

  private
  # This method returns the string the user has inserted
  def last_insert
    if @history.was_restored?
      @history.was_restored = false   # reset the flag
      return @history.last_tag.without_tags
    end
    StringExtractor.new(
      buffer, [@history.line_number, @history.start_pos], window.cursor
    ).extract_string
  end
end
