require File.dirname(__FILE__) + '/../spec_helper'

describe "insertion of a simple snippet" do
  include VimIntegrationHelper
  it "should insert the placeholder-snippet correctly" do
    with_vim do |vim|
    	vim.insert_string("if")
      vim.tab
      vim.tab
      vim.execute!.should == "if condition\n  \nend\n"
    end
  end

  it "should allow to edit the placeholder-snippet" do
    with_vim do |vim|
    	vim.insert_string("if")
      vim.tab
      vim.insert_string("edited")
      vim.tab
      vim.execute!.should == "if edited\n  \nend\n"
    end
  end

  it "should have no problems with indentation" do
    with_vim do |vim|
    	vim.insert_string("    if")
      vim.tab
      vim.tab
      vim.execute!.should == "    if condition\n      \n    end\n"
    end
  end

  it "should support other filetypes" do
    with_vim do |vim|
    	vim.file_extension = '.py'
      vim.insert_string("def")
      vim.tab
      vim.tab
      vim.execute!.should == "def method_name(params):\n\t\n"
    end
  end
end

describe "strange translation snippets" do
  include VimIntegrationHelper
  describe "insertion of the ruby-times-snippet" do
    it "should insert the default snippet correctly" do
      with_vim do |vim|
        vim.insert_string("tim")
        vim.tab
        vim.tab
        vim.execute!.should == "times { |n|  }\n"
      end
    end

    it "should insert the snippet correctly when pressing space" do
      with_vim do |vim|
        vim.insert_string("tim")
        vim.tab
        vim.insert_string(" ")
        vim.tab
        vim.execute!.should == "times {   }\n"
      end
    end
  end
end
