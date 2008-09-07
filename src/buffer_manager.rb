require 'inserter'
require 'snippet'
require 'snippet_loader'
require 'mirrorer'
require 'buffer_util/buffer_util'

require 'buffer_manipulators/restore_manipulator'
require 'buffer_manipulators/mirror_manipulator'
require 'buffer_manipulators/yank_saver_manipulator'
require 'buffer_manipulators/jumper_manipulator'
require 'buffer_manipulators/yank_restore_manipulator'

require 'buffer_manipulators/tag_history'

String.send(:include, GeditSnippetMatcher)

# This class responsible for managing the buffer with Snippets, Inserters.
# It is able to determine whether or not a current snippet should be inserted
# and is able to jump to the next snippet in the buffer.
class BufferManager
  attr_accessor :snippets, :buffer, :window

  # Initializes the Manager
  #
  # ==== Parameters 
  # window<Vim::Window>::
  #   The VIM-Window, used to get the position of the cursor
  # buffer<Vim::Buffer>::
  #   The VIM-Buffer, used to find/insert snippets
  def initialize(window=VIM::Window.current, buffer=VIM::Buffer.current)
    @window = window
    @buffer = buffer

    @snippet_loader = SnippetLoader.new

    monkey_patch_buffer!
    @manipulators = [
      RestoreManipulator.new(@window, @buffer),
      MirrorManipulator.new(@window, @buffer),
      YankRestoreManipulator.new(@window, @buffer),
      JumperManipulator.new(@window, @buffer),
      YankSaverManipulator.new(@window, @buffer)
    ]
    @history = TagHistory.new
  end

  # Monkeypatches the BufferUtil module into the buffer-object unless it's
  # already patched in.
  def monkey_patch_buffer!
    unless @buffer.respond_to? :buffer
      @buffer.class.send(:include, BufferUtil) 
    end
  end

  # Updates the buffer of the manager and of each of it's snippets with the 
  # given buffer.
  #
  # ==== Parameters
  # buf<Vim::Buffer>::
  #   The new, updated VI-Buffer
  # ---
  # @public
  def buffer=(buf)
    @buffer = buf
    @snippet_loader.current_snippets.each do |snippet|
      snippet.buffer = buf
    end
    @manipulators.each { |man| man.buffer = buf }
    monkey_patch_buffer!
    @buffer
  end

  # Updates the window of the manager and of each of it's snippets with the 
  # given window.
  #
  # ==== Parameters
  # win<Vim::Window>::
  #   The new, updated VI-Window
  # ---
  # @public
  def window=(win)
    @window = win
    @snippet_loader.current_snippets.each do |snippet|
      snippet.window = win 
    end
    @manipulators.each { |man| man.window = win }
  end

  # Jumps to the next tag in the buffer. If the tag is an extended tag, it'll
  # mark the contents of the tag with the cursor. 
  # ---
  # @public
  def jump
    @manipulators.inject(@history) { |h, man| man.manipulate!(h) }
  end

  # Handles the insertion of new snippets. If the last word in the buffer
  # matches any snippet, the snippet will be inserted in the buffer.
  # ---
  # @public
  def handle_insert
    snippet = @snippet_loader.current_snippets.find { |snip| snip.pressed? }
    if snippet
      snippet.insert_snippet 
      @history.clear
    end
  end
end

