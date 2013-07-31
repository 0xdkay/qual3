
list = Dir.glob("pages/*").select {|v| v =~ /.*\.rb/}
list.delete __FILE__

list.each do |v|
	require v
end

