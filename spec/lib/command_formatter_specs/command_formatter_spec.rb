require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe 'a command preprocessor' do
  include VimSpecHelper
  before(:each) do
    stub_vim
  end
  
	describe 'variable replacement' do
    it 'should recognize variables correctly' do
      CommandFormatter.new("$23NOVAR").format.should eql("$23NOVAR")
      CommandFormatter.new("$VAR").format.should eql("")
      CommandFormatter.new("$_VAR").format.should eql("")
    end

		it 'should replace VI_SELECTED_TEXT' do
      Vim.should_receive(:command).with("let snip_tmp = getreg()")
      Vim.should_receive(:evaluate).with('snip_tmp').and_return("SELECTED")
      CommandFormatter.new("$VI_SELECTED_TEXT").format.should eql("SELECTED")
    end
    
		it 'should replace VI_FILENAME' do
      Vim.should_receive(:command).with("let snip_tmp = @%")
      Vim.should_receive(:evaluate).with('snip_tmp').and_return("some/file")
      CommandFormatter.new("$VI_FILENAME").format.should eql("file")
    end

		it 'should replace VI_CURRENT_LINE' do
      Vim.should_receive(:command).with("let snip_tmp = getline(\".\")")
      Vim.should_receive(:evaluate).with('snip_tmp').and_return(
        "LINE"
      )
      CommandFormatter.new("$VI_CURRENT_LINE").format.should eql("LINE")
    end

		it 'should replace VI_DIRECTORY'
		it 'should replace VI_FILEPATH'
		it 'should replace VI_CURRENT_WORD'
		it 'should replace VI_LINE_INDEX'
		it 'should replace VI_LINE_NUMBER'
		it 'should replace VI_SOFT_TABS' do
      Vim.should_receive(:command).with("let snip_tmp = &expandtab")
      Vim.should_receive(:evaluate).with('snip_tmp').and_return(
        "1"
      )
      CommandFormatter.new("$VI_SOFT_TABS").format.should eql("YES")
    end

		it 'should replace VI_TAB_SIZE'
		it 'should replace environment variables' do
      CommandFormatter.new("$HOME").format.should eql(ENV["HOME"])
    end

		it 'should replace multiple variables' do
      CommandFormatter.new("$HOME $HOME").format.should eql(
        ENV["HOME"] + " " + ENV["HOME"]
      )
    end
	end

	describe 'handling of default values' do
		it 'should handle default values correctly' do
      CommandFormatter.new("${MISSING:default}").format.should eql(
        "default"
      )
    end

		it 'should handle default values correctly 2' do
      CommandFormatter.new("${HOME:default}").format.should eql(
        ENV["HOME"]
      )
    end

    it 'should handle multiple values correctly' do
      CommandFormatter.new("${MISSING:default} something ${HOME:default}").
        format.should eql("default something #{ENV['HOME']}")
    end

    it 'should not conflict with regular nested tags' do
      CommandFormatter.new("${MISSING:default} something ${1:tag} " + 
        "${HOME:default}"
      ).format.should eql("default something ${1:tag} #{ENV["HOME"]}")
    end

    # The ultimate spec :P
    it 'should allow nesting of tags' do
      CommandFormatter.new("${MISSING:${MISSING2:default2}} ${1:tag}"
      ).format.should eql("default2 ${1:tag}")
    end

    # The ultimate spec#2 :P
    it 'should not allow nesting in placeholder tags' do
      CommandFormatter.new("${1:tag${MISSING2:default2}}"
      ).format.should eql("${1:tag${MISSING2:default2}}")
    end
	end
  
	describe 'handling of shellcode' do
		it 'should pipe all between `` into the shell and replace it with ' + 
      'the result' do
      
      CommandFormatter.new("something `echo \"blub\"`").format.should eql(
        "something blub"
      )
    end

    it 'should export vim variables as environment variables for the shell' do
      Vim.stub!(:evaluate).with('snip_tmp').and_return("SELECTED")
      CommandFormatter.new('something `
        if [ $VI_SELECTED_TEXT = "SELECTED" ] 
        then
          echo "success"
        fi
      `').
        format.should eql('something success')
    end
	end

  describe 'handling of regexp' do
    before(:each) do
      Vim.stub!(:command).with("let snip_tmp = getreg()")
      Vim.stub!(:evaluate).with('snip_tmp').and_return("SELECTED")
    end
    
    it 'should recognize and apply regexps in tags' do
      CommandFormatter.new("something ${VI_SELECTED_TEXT/^.+$/- $0/g}").
        format.should eql("something - SELECTED")
    end

    it 'should have no problems with {} around numbers' do
      CommandFormatter.new("something ${VI_SELECTED_TEXT/^.+$/- ${0}/g}").
        format.should eql("something - SELECTED")
    end

    describe 'upcase' do
      before(:each) do
        Vim.stub!(:evaluate).with('snip_tmp').and_return("something SELECTED")
      end

      it 'should apply upcase correctly' do
        CommandFormatter.new("${VI_SELECTED_TEXT/^.+$/- \\u${0}/g}").
          format.should eql("- Something SELECTED")
      end

      it 'should apply big upcase correctly' do
        CommandFormatter.new("${VI_SELECTED_TEXT/^.+$/- \\U${0}/g}").
          format.should eql("- SOMETHING SELECTED")
      end

      it 'should stop correctly' do
        CommandFormatter.new(
          "${VI_SELECTED_TEXT/^(some)(thing)(.*)$/- \\U${1}\\E${2}$3/g}"
        ).format.should eql("- SOMEthing SELECTED")
      end
    end

    describe 'downcase' do
      before(:each) do
        Vim.stub!(:evaluate).with('snip_tmp').and_return("SOMETHING SELECTED")
      end

      it 'should apply downcase correctly' do
        CommandFormatter.new("${VI_SELECTED_TEXT/^.+$/- \\l${0}/g}").
          format.should eql("- sOMETHING SELECTED")
      end

      it 'should apply big downcase correctly' do
        CommandFormatter.new("${VI_SELECTED_TEXT/^.+$/- \\L${0}/g}").
          format.should eql("- something selected")
      end

      it 'should stop correctly' do
        CommandFormatter.new(
          "${VI_SELECTED_TEXT/^(SOME)(THING)(.*)$/- \\L${1}\\E${2}$3/g}"
        ).format.should eql("- someTHING SELECTED")
      end
    end
  end
end

describe "A command formatter with non-default tags" do
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

  it 'should replace variables correctly' do
    CommandFormatter.new("$[HOME:default]").format.should eql(
      ENV["HOME"]
    )
  end

  it 'should translate regexps correctly' do
    CommandFormatter.new("$[something selected/^.+$/- \\U${0}/g]").
      format.should eql("- SOMETHING SELECTED")
  end
end
