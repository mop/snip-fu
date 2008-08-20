require File.dirname(__FILE__) + '/manipulator_helper'

class YankRestoreManipulator  
  include ManipulatorHelper

  def manipulate!(history)
  	@history = history
    #return @history unless @history.start_pos && @history.line_number &&
    #  @history.last_tag.single_tag?
    return @history if @history.start_pos.nil? || @history.line_number.nil? || 
      @history.last_tag.single_tag?
    restore_yank 
    @history
  end

  private
  def last_edited
    StringExtractor.new(
      buffer, [@history.line_number, @history.start_pos], window.cursor
    ).extract_string
  end

  def restore_yank
    Vim.command(
      "call setreg(v:register, \"#{@history.yank.gsub(/"/, '\"')}\")"
    ) if @history.yank
  end
end
