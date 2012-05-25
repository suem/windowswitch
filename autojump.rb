#!/usr/bin/env ruby

OPEN_FILE_COMMAND = ARGV[0]
DMENU_ARGS = ARGV[1..-1]


def get_user_selection(entries)
  result = nil
  dmenu_command = ["dmenu"]
  dmenu_command.concat(DMENU_ARGS)
  IO.popen(dmenu_command.join(" "), "r+") do |f|
    f.puts(entries)
    f.close_write
    result = f.gets
  end
  result.chomp
end


def open_file(filename)
  system "#{OPEN_FILE_COMMAND}#{filename}"
end


data = ''
f = File.open(File.expand_path("~/.local/share/autojump/autojump.txt"), "r")
f.each_line do |line|
  data += line.split("\t")[1]
end
data.chomp!

selection = get_user_selection(data)
open_file(selection)
#system "gnome-terminal --working-directory="+selection

#select_file(ARGV[0],data)
