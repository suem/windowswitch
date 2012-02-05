#!/usr/bin/env ruby

def get_desktop_filenames(dirs)
	desktop_files = []
	dirs.each do |dir|
		file_names = Dir.entries(dir).select do |elem|
			elem.end_with? ".desktop"
		end		
		desktop_files.concat file_names.collect {|file_name| dir+file_name}	
	end
	desktop_files
end

def read_desktop_file(file_name)
	lines = File.readlines(file_name).collect {|l| l.chomp}
	
	entries = {}
	current_entry = {}
	
	lines.each do |line|
		if line =~ /^\[.*\]/
			current_entry = {}
			entries[line] = current_entry
		end
		if current_entry != nil and line =~ /.*=.*/ 
			key,value = line.split('=')
			current_entry[key] = value
		end
	end
	entries
	
end


def collect_applications(dirs)
	applications = {}
	desktop_filenames = get_desktop_filenames(dirs)
	desktop_filenames.each do |filename|
	 	entries = read_desktop_file(filename)
	 	desktop_entry = entries['[Desktop Entry]']
	 	if desktop_entry
	 		applications[desktop_entry['Name']] = desktop_entry['Exec']
	 	end
	end
	applications
end



def get_user_selection(windows)
	result = nil
	dmenu_command = ["dmenu"]
	dmenu_command.concat(ARGV)
	
	IO.popen(dmenu_command.join(" "), "r+") do |f|
	  f.puts(windows)
	  f.close_write
	  result = f.gets
	end		
	result
end

dirs = ["/usr/share/applications/", "/usr/local/share/applications/"]
applications = collect_applications(dirs)
user_selection = get_user_selection(applications.keys)
binary = applications[user_selection]
exec(binary) if binary

