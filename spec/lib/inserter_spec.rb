require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'A Inserter with an extended tag' do
  include VimSpecHelper
  before(:each) do
    stub_vim
    @buffer   = BufferStub.new(
      "some line before\nsome string for ${1:key} after\nnextline"
    )
    @mark     = "${1:key}"
    @inserter = Inserter.new(2, @mark, @buffer)
  end
  
	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_buffer!
    @buffer[2].should eql("some string for key after")
  end

	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(16)
  end

  it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(16 + @mark.length - 1)
  end

  it 'should return the correct key_directions' do
    @inserter.key_directions.should eql('\<Right>\<Right>')
  end
end

describe 'A inserter with a signle-sign extended tag' do
  before(:each) do
    @buffer = BufferStub.new('each { |${1:e}| ${0} }')
    @mark   = '${1:e}'
    @inserter = Inserter.new(1, @mark, @buffer)
  end

	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_buffer!
    @buffer[1].should eql("each { |e| ${0} }")
  end

	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(8)
  end

  it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(8 + @mark.length - 1)
  end

  it 'should return the correct key_directions' do
    @inserter.key_directions.should eql('')
  end
end

describe 'A Inserter with a regular tag' do
  before(:each) do
    @buffer   = BufferStub.new(
      "some line before\nsome string for ${1} after\nnextline"
    )
    @mark     = "${1}"
    @inserter = Inserter.new(2, @mark, @buffer)
  end
  
	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_buffer!
    @buffer[2].should eql("some string for  after")
  end

	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(16)
  end

	it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(16 + @mark.length - 1)
  end

  it 'should return the correct key_directions' do
    @inserter.key_directions.should eql('')
  end
end

describe 'A inserter handling a tag at the end of the line' do
  before(:each) do
    @buffer   = BufferStub.new(
      "def ${1:methodName}\n  ${0}\nend"
    )
    @mark     = "${1:methodName}"
    @inserter = Inserter.new(1, @mark, @buffer)
    @inserter.remove_tags_from_buffer!
  end

  it 'should remove the mark correctly' do
    @buffer[1].should eql('def methodName')
    @buffer[2].should eql('  ${0}')
    @buffer[3].should eql('end')
  end

  it 'should move the correct key_directions' do
    str = (1..9).map { |i| '\<Right>' }.join('')
    @inserter.key_directions.should eql(str)
  end
end

describe 'A Inserter with nested tags' do
	before(:each) do
    @buffer   = BufferStub.new(
      "some ${1:thing ${2: nested} after} after\nnextline"
    )
    @mark     = "${1:thing ${2: nested} after}"
    @inserter = Inserter.new(1, @mark, @buffer)
  end

	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_buffer!
    @buffer[1].should eql(
      "some thing ${2: nested} after after"
    )
  end
  
	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(5)
  end

	it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(33)
  end

  it 'should return the correct key_directions' do
    str = (1..23).map { |i| '\<Right>' }.join('')
    @inserter.key_directions.should eql(str)
  end
end

describe 'An inserter handling tags spanning over multiple lines' do
  before(:each) do
    @buffer   = BufferStub.new(
      "some ${1:thing\n ${2: nested} after} after\nnextline"
    )
    @mark     = "${1:thing\n ${2: nested} after}"
    @inserter = Inserter.new(1, @mark, @buffer)
  end

  it 'should remove the tag correctly' do
    @inserter.remove_tags_from_buffer!
    @buffer[1].should eql('some thing')
    @buffer[2].should eql(' ${2: nested} after after')
    @buffer[3].should eql('nextline')
  end

  it 'should have the correct start line' do
    @inserter.start_line.should eql(1)
  end

  it 'should have the correct end line' do
    @inserter.end_line.should eql(2)
  end

  it 'should have the correct start position' do
    @inserter.start_pos.should eql(5)
  end

  it 'should have the correct end position' do
    @inserter.end_pos.should eql(19)
  end

  it 'should return the correct key_directions' do
    str = (1..13).map { |i| '\<Right>' }.join('')
    @inserter.key_directions.should eql('\<Down>' + str)
  end
end

describe 'An inserter handling tags spanning over multiple empty lines' do
  before(:each) do
    @buffer   = BufferStub.new(
      "some ${1:thing\n\n\n ${2: nested} \n after}\nnextline"
    )
    @mark     = "${1:thing\n\n\n ${2: nested} \n after}"
    @inserter = Inserter.new(1, @mark, @buffer)
  end

  it 'should remove the tag correctly' do
    @inserter.remove_tags_from_buffer!
    @buffer[1].should eql('some thing')
    @buffer[2].should eql('')
    @buffer[3].should eql('')
    @buffer[4].should eql(' ${2: nested} ')
    @buffer[5].should eql(' after')
    @buffer[6].should eql('nextline')
  end

  it 'should have the correct start line' do
    @inserter.start_line.should eql(1)
  end

  it 'should have the correct end line' do
    @inserter.end_line.should eql(5)
  end

  it 'should have the correct start position' do
    @inserter.start_pos.should eql(5)
  end

  it 'should have the correct end position' do
    @inserter.end_pos.should eql(6)
  end

  it 'should return the correct key_directions' do
    str = (1..4).map { |i| '\<Down>' }.join('')
    @inserter.key_directions.should eql(str)
  end
end

describe 'an inserter with formats in extended tags' do
  describe 'with only one layer' do
    before(:each) do
      @buffer   = BufferStub.new(
        "some ${1:thing ${VAR:nested}}"
      )
      @mark     = "${1:thing ${VAR:nested}}"
      @inserter = Inserter.new(1, @mark, @buffer)
    end

    it 'should replace formats in extended tags' do
      @inserter.remove_tags_from_buffer!
      @buffer.contents[0].should eql('some thing nested')
    end

    it 'should return the correct key_directions afterwards' do
      @inserter.remove_tags_from_buffer!
      str = (1..11).map { |i| '\<Right>' }.join('')
      @inserter.key_directions.should eql(str)
    end
  end

  describe 'double nested' do
    before(:each) do
      @buffer   = BufferStub.new(
        "some ${1:thing ${2: nested ${VAR:default}}}"
      )
      @mark     = "${1:thing ${2: nested ${VAR:default}}}"
      @inserter = Inserter.new(1, @mark, @buffer)
    end

    it 'should not replace formats in extended tags' do
      @inserter.remove_tags_from_buffer!
      @buffer.contents[0].should eql('some thing ${2: nested ${VAR:default}}')
    end
  end
end

describe 'An inserter handling the rspec-it-tag' do
  before(:each) do
    @buffer   = BufferStub.new(
      "it \"should description\" ${3:do\n  ${0}\nend}"
    )
    @mark     = "${3:do\n  ${0}\nend}"
    @inserter = Inserter.new(1, @mark, @buffer)
    @inserter.remove_tags_from_buffer!
  end

  it 'should modify the buffer correctly' do
    @buffer[1].should == 'it "should description" do'
    @buffer[2].should == '  ${0}'
    @buffer[3].should == 'end'
    @buffer[4].should be_nil
  end

  it 'should return the correct key_directions' do
    @inserter.key_directions.should == "\\<Down>\\<Down>\\<Left>"
  end
end

describe "an Inserter handling a multiline string in the yank-buffer" do
  include VimSpecHelper
  before(:each) do
    stub_vim
    Vim.stub!(:evaluate).and_return("multiline\nyank\n")
    @buffer   = BufferStub.new(
      "begin\n${3:${VI_SELECTED_TEXT/(\A.*)|(.+)|\n\z/(?1:$0:(?2:\t$0))/g}}\nrescue\n  ${0}\nend"
    )
    @mark     = "${3:${VI_SELECTED_TEXT/(\A.*)|(.+)|\n\z/(?1:$0:(?2:\t$0))/g}}"
    @inserter = Inserter.new(2, @mark, @buffer)
    @inserter.remove_tags_from_buffer!
  end

  it "should insert the string correctly" do
    @buffer[1].should == "begin"
    @buffer[2].should == "\tmultiline"
    @buffer[3].should == "\tyank"
    @buffer[4].should == ""
    @buffer[5].should == "rescue"
    @buffer[6].should == "  ${0}"
    @buffer[7].should == "end"
  end

  it "should return the correct key_directions" do
    str = (1..4).map { |e| "\\<Right>" }
    @inserter.key_directions.should == "\\<Down>#{str}"
  end
end

describe "an inserter handling an edge case " do
  include VimSpecHelper
  before(:each) do
    stub_vim
    @buffer = BufferStub.new("${1:tag\n} ${0}")
    @mark   = "${1:tag\n}"
    @inserter = Inserter.new(1, @mark, @buffer)
    @inserter.remove_tags_from_buffer!
  end

  it "should insert the string correctly" do
    @buffer[1].should == "tag"
    @buffer[2].should == " ${0}"
  end

  it "should return the correct key-directions" do
    @inserter.key_directions.should == "\\<Right>\\<Right>"
  end
end
