require 'rubygems'
require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../src')

Dir[File.dirname(__FILE__) + '/../src/**/*.rb'].each do |file|
  require file rescue nil
end
