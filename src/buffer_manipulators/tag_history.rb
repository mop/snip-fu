# This class stores the previous inserted tag, line-number, and start-position
# (on which the tag was inserted).
class TagHistory
  attr_accessor :last_tag, :line_number, :start_pos, :yank

  # Initializes the object
  def initialize(tag=nil, line=nil, pos=nil)
  	@last_tag    = tag
  	@line_number = line
  	@start_pos   = pos
  end

  # Clears the object by setting all its attributes to nil
  def clear 
  	@start_pos    = nil
  	@last_tag     = nil
  	@line_number  = nil
    @was_restored = nil
    @yank         = nil
  end

  # Sets the was_restored flag
  #
  # ==== Parameters
  # flag<Bool>::
  #   The new value of the was_restored-flag.
  # ---
  # @public
  def was_restored=(flag)
  	@was_restored = flag
  end

  # Returns true if the tag was restored within the buffer.
  #
  # ==== Returns
  # Bool::
  #   True if the tag was restored, otherwise false.
  # ---
  # @public
  def was_restored?
  	@was_restored
  end

  # Returns true if the object was cleared.
  #
  # ==== Returns
  # Bool::
  #   True if the object is cleared, otherwise false
  # ---
  # @public
  def cleared?
  	@start_pos.nil? &&
      @last_tag.nil? &&
      @line_number.nil? &&
      @yank.nil? &&
      @was_restored.nil?
  end
end
