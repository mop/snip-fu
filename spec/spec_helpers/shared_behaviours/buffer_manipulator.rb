describe "a buffer manipulator", :shared => true do
  it "should be able to assign a window" do
    window = mock("window")
    @manipulator.window = window
    @manipulator.window.should == window
  end

  it "should be able to assign a buffer" do
    buffer = mock("buffer")
    @manipulator.buffer = buffer
    @manipulator.buffer.should == buffer
  end

  it "should respond to manipulate!" do
    @manipulator.should respond_to(:manipulate!)
  end

  it "should return the history on manipulate!" do
    history = stub_everything("history")
    buffer  = BufferStub.new("")
    window  = WindowStub.new(1, 1)
    @manipulator.window = window
    @manipulator.buffer = buffer
    @manipulator.manipulate!(history).should == history
  end
end
