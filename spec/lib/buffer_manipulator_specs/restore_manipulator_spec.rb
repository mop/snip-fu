require File.dirname(__FILE__) + '/../../spec_helper'

describe 'A RestoreManipulator' do
  def window
    @window ||= WindowStub.new(1, 4)
  end

  def buffer 
    @buffer ||= BufferStub.new("for  in val")
  end

  before(:each) do
    Vim = stub_everything
    @manipulator = RestoreManipulator.new
  end

  it 'should be able to assign a window' do 
    @manipulator.window = window
    @manipulator.window.should == window 
  end

  it 'should be able to assign a buffer' do 
    @manipulator.buffer = buffer
    @manipulator.buffer.should == buffer 
  end

  describe 'with a tag, which was not edited by the user' do
    before(:each) do
      @buffer = BufferStub.new("for  in val")
      @manipulator = RestoreManipulator.new(window, buffer)
      @history = TagHistory.new("${1:key}", 1, 4)
      @manipulator.manipulate!(@history)
    end

    it 'should restore the tag correctly' do 
      @buffer[1].should == 'for key in val'
    end

    it 'should set the was_restored flag on the history object' do
      @history.was_restored?.should be_true
    end
  end

  describe 'with a tag, which was manipulated by the user' do
    before(:each) do
      window.cursor = [1, 12]
      @buffer = BufferStub.new("for something in val")
      @manipulator = RestoreManipulator.new(window, buffer)
      @history = TagHistory.new("${1:key}", 1, 4)
      @manipulator.manipulate!(@history)
    end

    it 'should not restore the tag' do
      @buffer[1].should == "for something in val"
    end

    it 'should not set the was_restored flag' do
      @history.was_restored?.should_not be_true
    end
  end
end
