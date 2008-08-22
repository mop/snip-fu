require File.dirname(__FILE__) + '/../spec_helper'
describe 'A Configurator' do
  def config_dir
    ENV['HOME'] + '/.vim/snip-fu/config.yml'
  end
	describe 'when initializing' do
		it 'should load the config from a YAML-file' do
      YAML.should_receive(:load_file).with(config_dir).and_return({})
      SnipFu::Config.load
    end
	end
	describe 'when the config was successfully loaded' do
    before(:each) do
      YAML.stub!(:load_file).and_return({
        'start_tag' => '${',
        'end_tag'   => '}'
      })
      SnipFu::Config.load
    end
		it 'should store the start-tag' do
      SnipFu::Config[:start_tag].should == '${'
    end

		it 'should store the end-tag' do
      SnipFu::Config[:end_tag].should == '}'
    end

		it 'should store the regexp-escaped start-tag' do
      SnipFu::Config[:regex_start_tag].should == '\$\{'
    end

		it 'should store the regexp-escaped end-tag' do
      SnipFu::Config[:regex_end_tag].should == '\}'
    end
	end
	describe 'when the config was not successfully loaded' do
    before(:each) do
      YAML.stub!(:load_file).and_raise(RuntimeError.new)
      SnipFu::Config.load
    end
    
		it 'should have a default start-tag of ${' do
      SnipFu::Config[:start_tag].should == '${'
    end

		it 'should have a default end-tag of }' do
      SnipFu::Config[:end_tag].should == '}'
    end
	end

  describe 'when the config contains an invalid start_tag' do
    before(:each) do
      YAML.stub!(:load_file).and_return({
        'start_tag' => 'xx',
        'end_tag'   => 'x'
      })
      SnipFu::Config.load
    end

    it 'should default to ${' do
      SnipFu::Config[:start_tag].should == '${'
      SnipFu::Config[:end_tag].should == '}'
    end
  end

  valid_tags = [ ['$[', ']'], ['${', '}'], ['$<', '>'], ['$%', '%'] ].each do |o|
    start_tag, end_tag = o
    it "should allow the #{start_tag} tag" do
      YAML.stub!(:load_file).and_return({
        'start_tag' => start_tag,
        'end_tag'   => end_tag
      })
      SnipFu::Config.load
      SnipFu::Config[:start_tag].should == start_tag
      SnipFu::Config[:end_tag].should == end_tag
    end
  end
end
