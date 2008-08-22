require File.dirname(__FILE__) + "/../spec_helper"

describe 'A Mirrorer' do
  include VimSpecHelper
  before(:each) do
    stub_vim
  end

	describe 'with a simple mirror' do
		it 'should mirror placeholder tags with the same digit' do
      buffer = BufferStub.new('some ${1:thing} thing')
      Mirrorer.new(buffer, '${1:key}', 'replace').mirror_tags!
      buffer[1].should == 'some replace thing'
    end

		it 'should mirror regular tags' do
      buffer = BufferStub.new('some ${1} thing')
      Mirrorer.new(buffer, '${1:key}', 'replace').mirror_tags!
      buffer[1].should == 'some replace thing'
    end
	end

	describe 'with a translator' do
		it 'should apply the translation correctly' do
      buffer = BufferStub.new('some ${1/.*/\U$0/g} thing')
      Mirrorer.new(buffer, '${1:key}', 'replace').mirror_tags!
      buffer[1].should == 'some REPLACE thing'
    end
	end
end

describe 'A Mirrorer with other tags' do
  include VimSpecHelper
  before(:each) do
    stub_vim
    SnipFu::Config[:start_tag] = '$['
    SnipFu::Config[:end_tag]   = ']'
  end

  after(:each) do
    SnipFu::Config[:start_tag] = '${'
    SnipFu::Config[:end_tag]   = '}'
  end

	describe 'with a simple mirror' do
		it 'should mirror placeholder tags with the same digit' do
      buffer = BufferStub.new('some $[1:thing] thing')
      Mirrorer.new(buffer, '$[1:key]', 'replace').mirror_tags!
      buffer[1].should == 'some replace thing'
    end

		it 'should mirror regular tags' do
      buffer = BufferStub.new('some $[1] thing')
      Mirrorer.new(buffer, '$[1:key]', 'replace').mirror_tags!
      buffer[1].should == 'some replace thing'
    end
	end

	describe 'with a translator' do
		it 'should apply the translation correctly' do
      buffer = BufferStub.new('some $[1/.*/\U$0/g] thing')
      Mirrorer.new(buffer, '$[1:key]', 'replace').mirror_tags!
      buffer[1].should == 'some REPLACE thing'
    end
	end
end
