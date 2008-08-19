# This class stores the previous inserted tag, line-number, and start-position
# (on which the tag was inserted).
class TagHistory
  attr_accessor :last_tag, :line_number, :start_pos
end
