require File.dirname(__FILE__) + '/../../spec_helper'

describe 'A JumperManipulator' do
  include VimSpecHelper
  
  before(:each) do
    stub_vim
    @manipulator = JumperManipulator.new
  end
  it_should_behave_like "a buffer manipulator"

	describe 'when jumping to an extended tag' do
    before(:each) do
      stub_vim
      @buffer = BufferStub.new("for ${1:key} in ${2:val}")
      @window = WindowStub.new(1, 1)
      @history = TagHistory.new
      @manipulator = JumperManipulator.new(@window, @buffer)
      @manipulator.manipulate!(@history)
    end

		it 'should position the cursor at the beginning of the tag' do 
      @window.cursor.should == [ 1, 4 ]
    end

		it 'should use an inserter-object to remove the tags from the buffer' do
      @buffer[1].should == "for key in ${2:val}"
    end

    it 'should write into the history' do
      @history.last_tag.should == "${1:key}"
      @history.line_number.should == 1
      @history.start_pos.should == 4
    end

		it 'should use an inserter-object to return a result to vi' do
      Vim.received_commands.include?(
        "let result = \"\\<Esc>\\<Right>v\\<Right>\\<Right>\\o\\<c-g>\""
      ).should be_true
    end
	end

	describe 'when jumping to an regular tag' do
    before(:each) do
      stub_vim
      @buffer = BufferStub.new("for ${1} in ${2:val}")
      @window = WindowStub.new(1, 1)
      @history = TagHistory.new
      @manipulator = JumperManipulator.new(@window, @buffer)
      @manipulator.manipulate!(@history)
    end

		it 'should position the cursor at the beginning of the tag' do
      @window.cursor.should == [ 1, 4 ]
    end

		it 'should use an inserter-object to remove the tags from the buffer' do
      @buffer[1].should == "for  in ${2:val}"
    end
    
    it 'should write into the history' do
      @history.last_tag.should == "${1}"
      @history.line_number.should == 1
      @history.start_pos.should == 4
    end

		it 'should use an inserter-object to return a result to vi' do
      Vim.received_commands.include?(
        'let result = "VIM_HACK_NOTHING"'
      ).should be_true
    end
	end

	describe 'when no tags are found in the buffer' do
    before(:each) do
      stub_vim
      @buffer = BufferStub.new("for")
      @window = WindowStub.new(1, 1)
      @history = TagHistory.new("something", 1, 1)
      @manipulator = JumperManipulator.new(@window, @buffer)
      @manipulator.manipulate!(@history)
    end

		it 'should clear the history' do
      @history.should be_cleared
    end
	end

	describe 'when no tags are left in the buffer after removing tags' + 
           ' from the buffer' do
    before(:each) do
      stub_vim
      @buffer = BufferStub.new("for ${1}")
      @window = WindowStub.new(1, 1)
      @history = TagHistory.new("something", 1, 1)
      @manipulator = JumperManipulator.new(@window, @buffer)
      @manipulator.manipulate!(@history)
    end

    it 'should clear the history' do
      @history.should be_cleared
    end
  end
end

describe 'A JumperManipulator with other tags' do
  include VimSpecHelper
  before(:each) do
    SnipFu::Config[:start_tag] = '$['
    SnipFu::Config[:end_tag]   = ']'
  end

  after(:each) do
    SnipFu::Config[:start_tag] = '${'
    SnipFu::Config[:end_tag]   = '}'
  end

  describe 'jumping with a 0-mark' do
    before(:each) do
      @buffer = BufferStub.new("for $[0] in $[2:val]")
      @window = WindowStub.new(1, 1)
      @history = TagHistory.new
      @manipulator = JumperManipulator.new(@window, @buffer)
      @manipulator.manipulate!(@history)
    end

    it 'it should eliminate val' do
      @buffer[1].should == 'for $[0] in val'
    end
  end

end
