require File.dirname(__FILE__) + '/../spec_helper'

describe BufferManager, 'update of window/buffer' do
  before(:each) do
    @window = mock('window')
    @buffer = mock('buffer')
    @snippet = mock('Snippet')
    Snippet.stub!(:new).and_return(@snippet)

    @loader  = mock('Loader', :current_snippets => [@snippet])
    @loader.stub!(:load_snippets)
    SnippetLoader.stub!(:new).and_return(@loader)

    @manager = BufferManager.new(@window, @buffer)
  end

  it 'should send buffer= to each snippet when updating the buffer' do
    @snippet.should_receive(:buffer=).with(@buffer).any_number_of_times
    @manager.buffer = @buffer
  end

  it 'should send window= to each snippet when updating the buffer' do
    @snippet.should_receive(:window=).with(@buffer).any_number_of_times
    @manager.window = @buffer
  end
end

describe BufferManager, 'snippet insertion' do
  before(:each) do
    @buffer = BufferStub.new("for")
    @window = WindowStub.new(1, 3)
    @snippet = mock('snippet')
    Snippet.stub!(:new).and_return(@snippet)

    @loader  = mock('Loader', :current_snippets => [@snippet])
    @loader.stub!(:load_snippets)
    SnippetLoader.stub!(:new).and_return(@loader)

    @manager = BufferManager.new(@window, @buffer)
  end

  it 'should call pressed? on snippet' do
    @snippet.should_receive(:pressed?).any_number_of_times.and_return(false)
    @manager.handle_insert
  end

  it 'should call insert_snippet when a snippet was found' do
    @snippet.stub!(:pressed?).and_return(true)
    @snippet.should_receive(:insert_snippet)
    @manager.handle_insert
  end
end

describe BufferManager, 'jump' do
  before(:each) do
    Vim = stub_everything(:evaluate => ' ')
    @buffer = BufferStub.new("for ${1:key} in ${2:val}")
    @window = WindowStub.new(1, 1)
    @snippet = mock('Snippet', :buffer= => nil, :window= => nil)
    @snippet.stub!(:pressed?).and_return(false)

    Snippet.stub!(:new).and_return(@snippet)

    @loader  = mock('Loader', :current_snippets => [@snippet])
    @loader.stub!(:load_snippets)
    SnippetLoader.stub!(:new).and_return(@loader)

    @inserter = mock('inserter')
    @inserter.stub!(:remove_tags_from_buffer!)
    @inserter.stub!(:key_directions).and_return("")
    @inserter.stub!(:start_pos)
    Inserter.stub!(:new).and_return(@inserter)
    @manager = BufferManager.new(@window, @buffer)
  end

  describe 'inserter interaction' do
    it 'should initialize the Inserter correctly' do
      Inserter.should_receive(:new).with(1, "${1:key}", @buffer).
        and_return(@inserter)
      @manager.jump
    end

    it 'should call remove_tags_from_buffer! for the inserter' do
      @inserter.should_receive(:remove_tags_from_buffer!)
      @manager.jump
    end

    it 'should call key_directions and append them to the result' do
      @inserter.should_receive(:key_directions).and_return("DIRECTIONS")
      str = ""
      Vim.should_receive(:command).with(
        "let result = \"\\<Esc>\\<Right>vDIRECTIONS\\o\\<c-g>\""
      )
      @manager.jump
    end

    it 'should append VIM_HACK_NOTHING to result if the inserted tag was ' + 
       'a regular tag'do
      @buffer = BufferStub.new("for key in ${0}")
      @window = WindowStub.new(1, 1)
      @manager.buffer = @buffer
      @manager.window = @window
      str = ""
      Vim.should_receive(:command).with(
        "let result = \"VIM_HACK_NOTHING\""
      )
      @manager.jump
    end
  end

  describe 'untouched previous selections' do
    before(:each) do
      @backup = @buffer.contents[0]
      @buffer.contents[0] = "for  in ${2:val}"
      @window.cursor = [1, 4]
      @manager.instance_variable_set(:@last_edited, [ "${1:key}", 4, 1 ])
    end

    after(:each) do
      @buffer.contents[0] = @backup
      @window.cursor = [ 1, 2 ]
    end

    it 'should restore the buffer' do
      Snippet.should_receive(:new).with('', 'key').and_return(@snippet)
      @snippet.should_receive(:insert_snippet)
      @manager.jump
    end
  end

  describe 'handling of multi line snippets' do
    before(:each) do
      @backup = @buffer.contents
      @buffer.contents[0] = "for ${1:k"
      @buffer.contents[1] = "key} in ${2:val}"
    end

    after(:each) do
      @buffer.contents = @backup
    end

    it 'should should remove the tags correctly' do
      Inserter.should_receive(:new).with(1, "${1:k\nkey}", @buffer).
        and_return(@inserter)
      @manager.jump
    end
  end
end

describe BufferManager, 'restoring of same symbol' do
  before(:each) do
    Vim = stub_everything
    @buffer = BufferStub.new("for ${1:key} in ${2:val}")
    @window = WindowStub.new(1, 1)

    @inserter = mock('inserter')
    @inserter.stub!(:remove_tags_from_buffer!)
    @inserter.stub!(:key_directions).and_return("")
    @inserter.stub!(:start_pos)
    Inserter.stub!(:new).and_return(@inserter)

    @loader  = mock('Loader', :current_snippets => [@snippet])
    @loader.stub!(:load_snippets)
    SnippetLoader.stub!(:new).and_return(@loader)

    @manager = BufferManager.new(@window, @buffer)
  end

  describe 'restoring via template' do
    before(:each) do
      @backup = @buffer.contents
      @buffer.contents[0] = "for  ${1}"
      @manager.instance_variable_set(:@last_edited, [ "${1:key}", 4, 1 ])
      @manager.instance_variable_set(:@was_restored, true)
    end

    after(:each) do
      @buffer.contents = @backup
    end

    it 'should replace ${1}' do
      @manager.jump
      # we are not stubbing the insert here 
      @buffer.contents[0].should eql("for  key")
    end
  end

  describe 'restoring via input' do
    before(:each) do
      @backup = @buffer.contents
      @buffer.contents[0] = "for wohoo ${1}"
      @manager.instance_variable_set(:@last_edited, [ "${1:key}", 4, 1 ])
      @cursor_backup = @window.cursor
      @window.cursor = [ 1, 9 ]
    end

    after(:each) do
      @buffer.contents = @backup
      @window.cursor   = @cursor_backup
    end

    it 'should replace ${1}' do
      @manager.jump
      # we are not stubbing the insert here 
      @buffer.contents[0].should eql("for wohoo wohoo")
    end
  end

  describe 'restoring via input with multiple lines' do
    before(:each) do
      @backup = @buffer.contents
      @buffer.contents[0] = "for wo"
      @buffer.contents[1] = "hoo something ${1}"
      @manager.instance_variable_set(:@last_edited, [ "${1:key}", 4, 1 ])
      @cursor_backup = @window.cursor
      @window.cursor = [ 2, 3 ]
    end

    after(:each) do
      @buffer.contents = @backup
      @window.cursor   = @cursor_backup
    end
    
    it 'should replace ${1}' do
      @manager.jump
      # we are not stubbing the insert here 
      @buffer.contents[1].should eql("hoo something wo")
      @buffer.contents[2].should eql("hoo")
    end
  end

  describe 'mirroring extended tags' do
    before(:each) do
      @backup = @buffer.contents
      @buffer.contents[0] = "for wo"
      @buffer.contents[1] = "hoo something ${1:someotherkey}"
      @manager.instance_variable_set(:@last_edited, [ "${1:key}", 4, 1 ])
      @cursor_backup = @window.cursor
      @window.cursor = [ 2, 3 ]
    end

    after(:each) do
      @buffer.contents = @backup
      @window.cursor   = @cursor_backup
    end

    it 'should replace ${1:someotherkey}' do
      @manager.jump
      # we are not stubbing the insert here 
      @buffer.contents[1].should eql("hoo something wo")
      @buffer.contents[2].should eql("hoo")
    end
  end

  describe 'applying transformations on extended tags' do
    before(:each) do
      @backup = @buffer.contents
      @buffer.contents[0] = "for wo"
      @buffer.contents[1] = "hoo something ${1/wo/zomg/g}"
      @manager.instance_variable_set(:@last_edited, [ "${1:key}", 4, 1 ])
      @cursor_backup = @window.cursor
      @window.cursor = [ 2, 3 ]
    end

    after(:each) do
      @buffer.contents = @backup
      @window.cursor   = @cursor_backup
    end

    it 'should replace and transform ${1/wo/zomg}' do
      @manager.jump
      # we are not stubbing the insert here 
      @buffer.contents[1].should eql("hoo something zomg")
      @buffer.contents[2].should eql("hoo")
    end
  end
end

describe BufferManager, 'loading snippets' do
  before(:each) do
    @loader = mock("snippet loader")
    @loader.stub!(:load_snippets)
    SnippetLoader.stub!(:new).and_return(@loader)

    @buffer = BufferStub.new("for ${1:key} in ${2:val}")
    @window = WindowStub.new(1, 1)
  end
  
  it 'should load the snippets in the beginning' do
    @loader.should_receive(:load_snippets)
    @manager = BufferManager.new(@window, @buffer)
  end

  it 'should update the current_snippets on buffer= and insert=' do
    @manager = BufferManager.new(@window, @buffer)
    @loader.should_receive(:current_snippets).twice.and_return([])
    @manager.window = :new_win
    @manager.buffer = :new_buf
  end

  it 'should call current_snippets when inserting a new snippet' do
    @manager = BufferManager.new(@window, @buffer)
    @loader.should_receive(:current_snippets).and_return([])
    @manager.handle_insert
  end
end

