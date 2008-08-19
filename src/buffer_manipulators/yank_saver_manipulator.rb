# This class is responsible for storing the yank-position in the TagHistory if
# the inserted tag was an extended tag.
class YankSaverManipulator 
  attr_accessor :window, :buffer
	def initialize(window=nil, buffer=nil)
  	@window = window
    @buffer = buffer
  end

  def manipulate!(history)
    history.yank = Vim.evaluate("getreg()") \
      unless history.last_tag.single_tag? rescue nil
  	history
  end
end
