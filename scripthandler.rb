require 'sketchup.rb'
SKETCHUP_CONSOLE.clear

module ScriptHandler

    @@scripts = []
    class DirScanner
        def initialize(path)
            puts "initialize"
            @extra_plugin_path = path
            @sem = @extra_plugin_path+"/.sem"
        end

        def doload(checksem=false)
            pattern = "#{@extra_plugin_path}/*.rb"
            Dir[pattern].each() { |x|
                if (!checksem) or (File.mtime(x) > File.mtime(@sem))
                    touch
                    load(x)
                    puts "(Re-)loaded #{x}"
                end
            }
            nil
        end

        def touch
           File.new(@sem, "w").close()
        end
        
        def start_scanning
            puts "Scanning started"
            doload
            @timer_id = UI::start_timer(1, true) {
                doload(true)
            }
        end
        def stop_scanning()
            UI.stop_timer(@timer_id)
        end
    end

    class SketchupScript

        def initialize(root_path, entry_point_script, should_reload)
            @root_path = root_path
            add_entry_point_script(entry_point_script)
            @should_reload = should_reload
            @additional_reloads = []
            @scanner = DirScanner.new(root_path)
            self.start_watching_for_changes()
            self.require_main_script()
        end

        def start_watching_for_changes()
            #TODO make dirscanner work for files in additional_reloads instead of whole directorty
            @scanner.start_scanning()
        end

        def stop_watching_for_changes()
            @scanner.stop_scanning()
        end

        def require_main_script
            require @entry_point_script
        end

        def reload
            if @should_reload then
                puts "reloading #{@entry_point_script}..."
                load @entry_point_script

                for script in @additional_reloads do
                    puts "reloading #{script}..."
                    load script
                end
            end
        end

        def doload
            for script in @additional_reloads do

                if (!checksem) or (File.mtime(script) > File.mtime(@sem))
                    touch
                    load(x)
                    puts "(Re-)loaded #{script}"
                end
            end
        end
        def touch
            File.new(@sem, "w").close()
        end

        def watch_for_changes
            doload
            UI::start_timer(1, true) {
               doload(true)
            }
        end

        def add_entry_point_script(path)
            path = make_absolute(path)
            @entry_point_script = path
            puts "Setting #{path} as main script entry point"

        end

        def add_folder_to_reload(path,include_subfolders)
            path = make_absolute(path)
            folders = include_subfolders ? '**' : '*'
            pattern = File.join(path, folders, '*.rb')
            Dir.glob(pattern).each { |filename|
                #@additional_reloads.push(filename)
                puts "added #{filename} to list of scripts to reload"
            }
        end

        def add_script_to_reload(path)
            script_path = make_absolute(path)
            @additional_reloads.push(script_path)
            puts "added #{script_path} to list of scripts to reload"

        end

        def make_absolute(path)
            if path.include?(@root_path) then 
                return path
            else
                return File.join(@root_path,path)
            end
        end
    end

    def self.reload()
        puts "Reloading scripts..."
        for script in @@scripts do
            script.reload()
        end
        puts "Finished reloading."
    end

    def self.stop_watching_for_script_changes()
        for script in @@scripts do
            script.stop_watching_for_changes()
        end
        puts "Stopped looking for changes scripts..."
    end

    def self.add_script(folder,script_file_name,should_reload)
        script = SketchupScript.new(folder,script_file_name,should_reload)
        @@scripts.push(script)
    end
    
end


