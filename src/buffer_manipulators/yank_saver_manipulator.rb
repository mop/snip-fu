require File.dirname(__FILE__) + '/manipulator_helper'

# This class is responsible for storing the yank-position in the TagHistory if
# the inserted tag was an extended tag.
class YankSaverManipulator 
  include ManipulatorHelper

  def manipulate!(history)
    history.yank = Vim.evaluate("getreg()") \
      unless history.last_tag.single_tag? rescue nil
  	history
  end
end
