
OPEN_FILE_COMMAND = ARGV[1]
DMENU_ARGS = ARGV[2..-1]


def get_user_selection(windows, message)
  result = nil
  dmenu_command = ["dmenu", "-p", message]
  dmenu_command.concat(DMENU_ARGS)

  IO.popen(dmenu_command.join(" "), "r+") do |f|
    f.puts(windows)
    f.close_write
    result = f.gets
  end
  result
end


def select_file(basedir)

  basedir = File.expand_path(basedir)

  files = Dir.new(basedir).entries

  selection_list = []

  files.each do |f|
    if f != "." && f != ".."
      if File.directory?(basedir+"/"+f)
        selection_list << f+"/"
      else
        selection_list << f
      end
    end
  end

  hidden_files = selection_list.select {|s| s.start_with?(".")}
  normal_files = selection_list.select {|s| !s.start_with?(".")}

  hidden_files.sort_by {|a| a.downcase}
  normal_files.sort_by {|a| a.downcase}

  selection_list = ["./","../"]
  selection_list = selection_list + normal_files + hidden_files
  
  
  user_selection = get_user_selection(selection_list, basedir)

  if user_selection != nil
    user_selection.chomp!
    if user_selection == "./"
      open_file(basedir)
    elsif user_selection.end_with?("/")
      select_file(basedir+'/'+user_selection)
    else
      open_file(basedir+'/'+user_selection)
    end
  end

end

def open_file(filename)
  system "#{OPEN_FILE_COMMAND} #{filename}"
end



select_file(ARGV[0])
