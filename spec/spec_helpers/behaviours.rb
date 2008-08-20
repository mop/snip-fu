dir = File.dirname(__FILE__)
Dir["#{dir}/behaviours/**/*.rb"].each do |file|
	require file
end
