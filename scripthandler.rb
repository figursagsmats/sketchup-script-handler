module ScriptHandler
    class ScriptFileWatcher
        def initialize(script_path, is_single_file=false)
            @is_single_file = is_single_file
            @dir_path = File.dirname(script_path)
            @script_path = script_path
            @prev_ruby_files = []
            @main_script = script_path.split("/").last # /some/path/to/script/main.rb => main.rb
            main_script_name = @main_script.split(".").first #eg main.rb => main
            
            #sem is just using a file as a variable for last modified time
            if (is_single_file)
                @sem = @dir_path + "/." + main_script_name + ".sem"
            else
                @sem = @dir_path + "/.sem"
                @pattern = @dir_path + "/**/*.rb"
            end
            require script_path
            update_last_modified_time()
            start_scanning()
        end

        def find_all_ruby_files()

            if (@is_single_file)
                all_ruby_files = [@script_path]
            else
                all_ruby_files = Dir.glob(@dir_path + "/**/*.rb")
            end
        end

        def check_all_files()
            all_ruby_files = find_all_ruby_files()

            #Has the list of files changed?
            diff = all_ruby_files - @prev_ruby_files
            unless(diff.empty?)
                puts "Added the following files to the watch list:"
                all_ruby_files.each() { |x| puts x }
                puts "The complete watch list is now:"
                all_ruby_files.each() { |x| puts x }
            end

            @prev_ruby_files = all_ruby_files

            all_ruby_files.each() { |x|
                if (File.mtime(x) > File.mtime(@sem))
                    update_last_modified_time()
                    puts "Reloading #{x}..."
                    load(x)
                    puts "Done reloading #{x}!"
                end
            }
            nil
        end

        def update_last_modified_time
            File.new(@sem, "w").close()
        end

        def start_scanning
            #Starting timer that checks all ruby files for changes
            @timer_id = UI::start_timer(1, true) {
                check_all_files()
            }
        end

        def stop_scanning() #No use for this yet
            UI.stop_timer(@timer_id)
        end

    end

    def self.add_single_file_script(script_path)
        ScriptFileWatcher.new(script_path, true)
    end
    
    def self.add_multi_file_script(script_path)
        ScriptFileWatcher.new(script_path, false)
    end
end

