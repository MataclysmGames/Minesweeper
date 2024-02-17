godot_console.exe --headless --export-release "Windows Desktop" --quiet 2>$null
godot_console.exe --headless --export-release "Web" --quiet 2>$null

butler push C:\Users\matte\Documents\Games\Minesweeper\Windows\ mataclysm/Minesweeper:windows
butler push C:\Users\matte\Documents\Games\Minesweeper\Web\ mataclysm/Minesweeper:html
