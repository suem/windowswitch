#!/usr/bin/env ruby


class WindowManager

	def initialize
		@hostname = IO.popen('hostname').read
		@hostname.chomp!
	end

	def windows
		window_list = []
		IO.popen("wmctrl -l") do |p|
			p.each do |line|
				if !line.match("-1")
					window_list << line[line.index(@hostname)+@hostname.length+1,line.length].chomp	
				end		
			end
		end		
		window_list
	end
	
	def get_window_by_id(id)
		hex = sprintf("%02x", id ).downcase
		hex = "0x0#{hex}"
		result = nil
		IO.popen("wmctrl -l") do |p|
			p.each do |line|
				if line.match(hex)
					result = line[line.index(@hostname)+@hostname.length+1,line.length].chomp	
				end		
			end
		end
		result
	end
	
	def get_active_window
		id = IO.popen('xdotool getactivewindow').read
		id.chomp!
		get_window_by_id(id.to_i)
	end


	def activate_window(name)
		system( "wmctrl -a '#{name}'") if name != nil		
	end

end

class History
	
	def initialize
		@file_name = File.expand_path("~/.cache/window_history")
	end
	
	def get_history_list
		lines = File.readlines(@file_name)	
		lines.each { |l| l.chomp!}
	end
	
	def safe_history_list(history)
		File.open(@file_name, "w") do |f|
			history.each do |h|
				f.puts(h)
			end
		end
	end

end


class Dmenu
	
	def initialize
		@history = History.new			
		@window_manager = WindowManager.new
	end
	
	def window_list
		history_list = @history.get_history_list
		current_list = @window_manager.windows
		
		new_list = []
				
		history_list.each do |h|
			if current_list.include? h
				new_list << h
			end
		end
		
		new_items = current_list.reject {|i| new_list.include?(i)}
		new_list.concat(new_items)		
		
		new_list
	end
	
	def switch_window
		windows = window_list
		active = @window_manager.get_active_window
		selection = get_user_selection(windows)
		
		# move active to position 1		
		windows.delete(active)
		windows.insert(0,active)
		
		@history.safe_history_list(windows)
		@window_manager.activate_window(selection)
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
	
end


dmenu = Dmenu.new
dmenu.switch_window	

