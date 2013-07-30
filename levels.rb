
list = Dir.glob("levels/*").select {|v| v =~ /level.*/}
list.delete __FILE__

list.each do |v|
	require v
end

