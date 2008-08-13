require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'A Inserter with an extended tag' do
  before(:each) do
    @buffer   = BufferStub.new(
      "some line before\nsome string for ${1:key} after\nnextline"
    )
    @mark     = "${1:key}"
    @inserter = Inserter.new(2, @mark, @buffer)
  end
  
	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_line.should eql("some string for key after")
  end

	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(16)
  end

  it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(16 + @mark.length - 1)
  end

	it 'should map the correct number of elements' do
    i = 0
    @inserter.map_elements { |e| i += 1 }
    i.should eql(2)
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
    @inserter.remove_tags_from_line.should eql("each { |e| ${0} }")
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
    @inserter.remove_tags_from_line.should eql("some string for  after")
  end

	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(16)
  end

	it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(16 + @mark.length - 1)
  end
    
	it 'should map the correct number of elements' do
    i = 0
    @inserter.map_elements { |e| i += 1 }
    i.should eql(0)
  end

  it 'should return the correct key_directions' do
    @inserter.key_directions.should eql('')
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
    @inserter.remove_tags_from_line.should eql(
      "some thing ${2: nested} after after"
    )
  end
  
	it 'should have the correct start position for the tag' do
    @inserter.start_pos.should eql(5)
  end

	it 'should have the correct end position for the tag' do
    @inserter.end_pos.should eql(33)
  end

	it 'should map the correct number of elements' do
    i = 0
    @inserter.map_elements { |z| i += 1 }
    i.should eql(23)
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

  it 'should have the correct elements count' do
    i = 0
    @inserter.map_elements { |z| i += 1 }
    i.should eql(24)
  end

	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_line.should eql(
      "some thing"
    )
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

	it 'should remove the tag from the buffer correctly' do
    @inserter.remove_tags_from_line.should eql(
      "some thing"
    )
  end

  it 'should return the correct key_directions' do
    str = (1..4).map { |i| '\<Down>' }.join('')
    @inserter.key_directions.should eql(str)
  end
end
