require 'buffer_manager'

def buffer_manager
  @buffer_manager ||= BufferManager.new
end

def jump_to_mark
  begin
    # Update the buffer manager and all subsequent snippets to use the
    # _current_ Buffer + Window
    buffer_manager.buffer = VIM::Buffer.current
    buffer_manager.window = VIM::Window.current
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

