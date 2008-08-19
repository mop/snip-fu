require File.dirname(__FILE__) + "/../../spec_helper"
describe "a mirror manipulator " do
  def window
    @window ||= WindowStub.new(1, 3)
  end

  def buffer 
  	@buffer ||= BufferStub.new("def")
  end

  before(:each) do
    @mirrorer = MirrorManipulator.new
  end

  it "should be able to update it's window" do 
    @mirrorer.window = window
    @mirrorer.window.should == window
  end

  it "should be able to update it's buffer " do
    @mirrorer.buffer = buffer
    @mirrorer.buffer.should == buffer 
  end

  describe "when an item was previously edited" do
    before(:each) do
      @mirrorer.window = window
      @mirrorer.buffer = buffer

      @mirror = stub("Mirroer")
      Mirrorer.stub!(:new).and_return(@mirror)
      @history = TagHistory.new("tag", 1, 1)
    end

    it "should call the mirrorer object" do
      Mirrorer.should_receive(:new).with(buffer, "tag", "ef").and_return(
        @mirror
      )
      @mirror.should_receive(:mirror_tags!)
      @mirrorer.manipulate!(@history)
    end
  end

  describe "when the item was previously restored" do
    before(:each) do
      @mirrorer.window = window
      @mirrorer.buffer = buffer

      @mirror = stub("Mirroer")
      Mirrorer.stub!(:new).and_return(@mirror)
      @history = TagHistory.new("${1:tag}", 1, 1)
      @history.was_restored = true
    end

    it "should use the last-tag of the history object" do
      Mirrorer.should_receive(:new).with(buffer, "${1:tag}", "tag").and_return(
        @mirror
      )
      @mirror.should_receive(:mirror_tags!)
      @mirrorer.manipulate!(@history)
    end
  end

  describe "when nothing was previously edited" do
    before(:each) do
      @mirrorer.window = window
      @mirrorer.buffer = buffer

      @mirror = stub("Mirroer")
      Mirrorer.stub!(:new).and_return(@mirror)
      @history = TagHistory.new
    end

    it "should not call the mirrorer" do
      Mirrorer.should_not_receive(:new)
      @mirrorer.manipulate!(@history)
    end
  end
end
