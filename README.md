# sketchup-script-handler
1. Download scripthandler.rb and place it in your plugins-folder. That way is gets loaded when you start SketchUp.
2. Use another file (existing or new) in your plugins-folder to to consume the ScriptHandler-module like this:
```
require 'scripthandler.rb'
ScriptHandler.add_multi_file_script("C:/path/to/your/main/script.rb")
```
