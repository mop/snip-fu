require File.dirname(__FILE__) + "/../../spec_helper.rb"

describe 'A YankSaverManipulator' do
  before(:each) do
    @manipulator = YankSaverManipulator.new
  end

  it_should_behave_like "a buffer manipulator"

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
