require File.dirname(__FILE__) + '/../../spec_helper'

describe 'A JumperManipulator' do
  before(:each) do
    Vim = stub_everything
    @manipulator = JumperManipulator.new
  end
	it 'should be able to assign a window' do 
    buffer = mock('buffer')
  	@manipulator.buffer = buffer
    @manipulator.buffer.should == buffer 
  end

	it 'should be able to assign a buffer' do 
  	window = mock('window')
    @manipulator.window = window
    @manipulator.window.should == window 
  end

	describe 'when jumping to an extended tag' do
    before(:each) do
      Vim = stub_everything
      Vim.instance_eval do
        def command(arg)
          @commands ||= []
          @commands << arg
        end

        def received_commands
          @commands
        end
      end
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
      p Vim.received_commands
      Vim.received_commands.include?(
        "let result = \"\\<Esc>\\<Right>v\\<Right>\\<Right>\\o\\<c-g>\""
      ).should be_true
    end
	end

	describe 'when jumping to an regular tag' do
    before(:each) do
      Vim = stub_everything
      Vim.instance_eval do
        def command(arg)
          @commands ||= []
          @commands << arg
        end

        def received_commands
          @commands
        end
      end
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
      Vim = stub_everything
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
      Vim = stub_everything
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
