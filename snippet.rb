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
\\}${20:, { :${25:user} =&gt; ${26:@user} \\}}})"
      ),
      Snippet.new(
        "aftp",
        "after Proc.new { |c| ${1:c.some_method} \\}${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}"
      )
    ]
  end

  def jump
    buffer_line_cycle.each do |line|
      str = String.new(buffer[line])
      matches = str.scan_snippets
      next unless matches.size > 0
      
      match = matches.sort.first
      position_cursor(line, match)
      remove_mark(line, match)
      break
    end
  end

  def remove_mark(line, mark)
    beginning = mark.match(/(\$\{\d+:?)/)[0]
    pos = buffer[line].index(beginning)
    str = buffer[line]
    str[pos + mark.length - 1] = ""
    str[pos, beginning.length] = ""
    rights = (0...(mark.length - beginning.length - 2)).map { |i| "\\<Right>" }
    Vim::command("let result = \"\\<Esc>\\<Right>v#{rights}\\o\\<c-g>\"")
    buffer[line] = str
  end

  def position_cursor(line, match)
    window.cursor = [ line, buffer[line].index(match) ]
  end

  def handle_insert
    snippet = @snippets.find { |snip| snip.pressed? }
    snippet.insert_snippet rescue nil
  end

  def line_regexp
    # matches $0-9 marks and ${233:word} marks
    /\$\{\d+:?.*?\}/
  end

  def buffer_line_cycle
    ((buffer.line_number..buffer.count).to_a + 
    (1..buffer.line_number).to_a).uniq
  end

  def buffer_contents
    (0..(buffer.count)).map { |i| buffer[i] }.join
  end

  def window
    VIM::Window.current
  end

  def buffer
    VIM::Buffer.current
  end
end

def buffer_manager
  @buffer_manager = BufferManager.new
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
  if result == \"\"
    let result = \"\\<Tab>\"
  endif
  return result
endfunction")
VIM::command("
imap <silent> <script> <Tab> <C-R>=JumpToMark()<CR>
")
