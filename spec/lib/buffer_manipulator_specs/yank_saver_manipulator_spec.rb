require File.dirname(__FILE__) + "/../../spec_helper.rb"
describe 'A YankSaverManipulator' do
  before(:each) do
    @manipulator = YankSaverManipulator.new
  end

	it 'should assign a window' do 
  	window = mock('window')
    @manipulator.window = window
    @manipulator.window.should == window
  end

	it 'should assign a buffer' do 
  	buffer = mock('buffer')
    @manipulator.buffer = buffer
    @manipulator.buffer.should == buffer
  end

	describe 'after inserting an extended tag' do
    before(:each) do
    	Vim = stub_everything
      @manipulator = YankSaverManipulator.new
      @history = TagHistory.new("${1:extended}", 1, 1)
    end

		it 'should save the register into the history' do 
      Vim.should_receive(:evaluate).with("getreg()").and_return('yank')
      @manipulator.manipulate!(@history)
      @history.yank.should == 'yank'
    end
	end

	describe 'after inserting an regular tag' do
    before(:each) do
    	Vim = stub_everything
      @manipulator = YankSaverManipulator.new
      @history = TagHistory.new("${1}", 1, 1)
    end

		it 'should not save the register into the history'  do
      Vim.should_not_receive(:evaluate).with("getreg()").and_return('yank')
      @manipulator.manipulate!(@history)
      @history.yank.should be_nil
    end
	end
end
