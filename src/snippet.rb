require 'matcher'

String.send(:include, GeditSnippetMatcher)

# This class represents a snipped
class Snippet
  attr_accessor :key, :command
  def initialize(key, command)
    @key     = key
    @command = command
  end

  def pressed?
    last_word == @key
  end
  
  def insert_snippet
    str = buffer.line
    commands = @command.split("\n")

    str[last_word_start, @key.size] = commands.first
    buffer.line = str
    commands[1..commands.size].reverse.each do |c| 
      VIM::command("call append(\".\", \"#{c}\")")
    end
  end

  private
  def buffer
    VIM::Buffer.current
  end

  def last_word
    buffer.line[last_word_start, @key.size]
  end

  def cursor_column
    line, col = VIM::Window.current.cursor
    col
  end

  def last_word_start
    cursor_column - @key.size 
  end
end

class BufferManager
  attr_accessor :snippets
  def initialize
    @snippets ||= [
      Snippet.new(
        "for",
        "for ${0:key} in ${1:vals}\n${2}\nend\n${3}"
      ),
      Snippet.new(
        "send_mail",
        "send_mail(${1:${2:Some}Mailer}, :${3:mailer_action}${5:, {
	:from =&gt; ${10:'${11:from@acme.com}'}, 
	:to =&gt; ${12:'${13:some@user.com}'},
	:subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }}})"
      ),
      Snippet.new(
        "aftp",
        "after Proc.new { |c| ${1:c.some_method} }${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}"
      )
    ]
  end

  def jump
    restore_previous if previous_not_edited?
    buffer_line_cycle.each do |line_number|
      matches = buffer[line_number].scan_snippets
      next unless matches.size > 0
      
      match = matches.sort.first
      position_cursor(line_number, match)
      remove_mark(line_number, match)
      break
    end
  end

  def restore_previous
    return unless @last_edited
    start_pos, line_number = @last_edited[1, 2]
    str = buffer[line_number] 
    str[start_pos - 1] = str[start_pos - 1].chr + previous_selection
    buffer[line_number] = str
  end

  def previous_selection
    return nil unless @last_edited
    @last_edited[0].without_tags
  end

  def log
    File.open("/home/nax/vimdebug.txt", "a") do |f|
      yield f
    end
  end

  def buffer_matches?
    Vim::command("let tmpbuf = getreg()") 
    lastbuf = Vim::evaluate("tmpbuf")
    previous_selection == lastbuf
  end

  def previous_not_edited?
    previous_selection && previous_selection != "" &&
      buffer_matches?
  end

  def remove_mark(line_number, mark)
    inserter = Inserter.new(line_number, mark, buffer)
    no_tags  = inserter.remove_tags_from_line
    rights   = inserter.map_elements { |i| "\\<Right>" }
    make_result(rights)
    @last_edited = [mark, inserter.start_pos, line_number]
    buffer[line_number] = no_tags
  end

  def make_result(rights)
    if rights.size > 0
      Vim::command("let result = \"\\<Esc>\\<Right>v#{rights}\\o\\<c-g>\"") 
    else
      Vim::command("let result = \"VIM_HACK_NOTHING\"") # HACK
    end
  end

  def position_cursor(line, match)
    window.cursor = [ line, buffer[line].index(match) ]
  end

  def handle_insert
    snippet = @snippets.find { |snip| snip.pressed? }
    snippet.insert_snippet rescue nil
  end

  def buffer_line_cycle
    ((buffer.line_number..buffer.count).to_a + 
    (1..buffer.line_number).to_a).uniq
  end

  def window
    VIM::Window.current
  end

  def buffer
    VIM::Buffer.current
  end
end

class Inserter
  attr_accessor :line_number, :mark, :buffer, :start_pos, :end_pos
  def initialize(line_number, mark, buffer)
    @line_number = line_number
    @mark        = mark
    @buffer      = buffer
  end

  def remove_tags_from_line
    line[end_pos] = ""                      # Remove the end
    line[start_pos, start_tag.length] = ""  # Remove the start
    line
  end

  def map_elements
    (0...(mark.length - start_tag.length - 2)).map { |i| yield i }
  end

  def start_pos
    @start_pos ||= line.index(start_tag)
  end

  def end_pos
    @end_pos ||= start_pos + mark.length - 1
  end

  private
  def line
    @line ||= @buffer[@line_number].dup
  end

  def start_tag
    @start_tag ||= mark.match(/(\$\{\d+:?)/)[0]
  end

end

def buffer_manager
  @buffer_manager ||= BufferManager.new
end


def jump_to_mark
  begin
    buffer_manager.handle_insert
    buffer_manager.jump
  rescue => e
    File.open("/home/nax/vimdebug.txt", 'w') do |f|
      f.write(e)
      f.write(e.backtrace.join("\n"))
    end
  end
end

VIM::command("function! JumpToMark()
  let result = \"\"
  ruby jump_to_mark()
  if result == \"VIM_HACK_NOTHING\"
    return \"\"
  endif
  if result == \"\"
    let result = \"\\<Tab>\"
  endif
  return result
endfunction")
VIM::command("
inoremap <silent> <script> <Tab> <C-R>=JumpToMark()<CR>
")
