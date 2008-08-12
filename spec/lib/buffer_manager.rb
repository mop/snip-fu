require File.dirname(__FILE__) + '/../spec_helper'

describe BufferManager, 'update of window/buffer' do
  before(:each) do
    @window = mock('window')
    @buffer = mock('buffer')
    @snippet = mock('Snippet')
    Snippet.stub!(:new).and_return(@snippet)
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
    Vim = stub_everything
    @buffer = BufferStub.new("for ${1:key} in ${2:val}")
    @window = WindowStub.new(1, 1)
    @snippet = mock('Snippet')
    @snippet.stub!(:pressed?).and_return(false)

    Snippet.stub!(:new).and_return(@snippet)

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

    it 'should append VIM_HACK_NOTHING to result if the directions are empty'do
      @inserter.should_receive(:key_directions).and_return("")
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
