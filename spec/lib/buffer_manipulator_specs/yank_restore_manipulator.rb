require File.dirname(__FILE__) + "/../../spec_helper"

describe 'A YankRestoreManipulator' do
  before(:each) do
    @manipulator = YankRestoreManipulator.new
  end

	it 'should assign a window' do 
  	window = mock("window")
    @manipulator.window = window
    @manipulator.window.should == window
  end

	it 'should assign a buffer' do 
  	buffer = mock("buffer")
    @manipulator.buffer = buffer
    @manipulator.buffer.should == buffer
  end

	describe 'when restoring an extended tag' do
    before(:each) do
      Vim = stub_everything
      @manipulator = YankRestoreManipulator.new
      @history = TagHistory.new("${1:tag}", 1, 1)
      @history.was_restored = true
      @history.yank = 'ya"nk'
    end

		it 'should restore the yank-buffer' do 
      Vim.should_receive(:command).with('call setreg(v:register, "ya\"nk")')
    	@manipulator.manipulate!(@history)
    end
	end
	describe 'when manipulating a tag' do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new("for edited in ${2:val}")
      @window = WindowStub.new(1, 9)
      @manipulator = YankRestoreManipulator.new(@window, @buffer)
      @history = TagHistory.new("${1:tag}", 1, 4)
      @history.yank = 'yank'
    end

		it 'should restore the yank-buffer' do 
      Vim.should_receive(:command).with('call setreg(v:register, "yank")')
    	@manipulator.manipulate!(@history)
    end
	end
	describe 'when just jumping to a regular tag' do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new("for  in ${2:val}")
      @window = WindowStub.new(1, 4)
      @manipulator = YankRestoreManipulator.new(@window, @buffer)
      @history = TagHistory.new("${1}", 1, 4)
      @history.yank = 'yank'
    end

		it 'should not restore the yank-buffer' do
      Vim.should_not_receive(:command).with('call setreg(v:register, "yank"')
    	@manipulator.manipulate!(@history)
    end
	end
end
