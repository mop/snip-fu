class YankRestoreManipulator  
  attr_accessor :window, :buffer

	def initialize(window=nil, buffer=nil)
    @window = window
    @buffer = buffer
  end

  def manipulate!(history)
  	@history = history
    restore_yank if @history.was_restored? || last_edited != ""
    @history
  end

  private
  def last_edited
    if @history.was_restored?
      @history.was_restored = false   # reset the flag
      return @history.last_tag.without_tags
    end
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
