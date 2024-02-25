## Play Online
https://mataclysm.itch.io/minesweeper

### Feature Requests
Initial development is complete.
Comment on the itch page above for any bug fixes or feature requests.

## Requirements
- Install [Godot Engine 4.2.1](https://godotengine.org/download/windows/)
- Install [Butler](https://itch.io/docs/butler/installing.html)

## Build
```
godot_console.exe --headless --export-release "Windows Desktop" --quiet 2>$null
godot_console.exe --headless --export-release "Web" --quiet 2>$null
```

## Publish
```
butler push C:\Users\matte\Documents\Games\Minesweeper\Windows\ mataclysm/Minesweeper:windows
butler push C:\Users\matte\Documents\Games\Minesweeper\Web\ mataclysm/Minesweeper:html
```

## Host Web Build Locally
```
dotnet tool install --global dotnet-serve
dotnet serve --directory C:\Users\matte\Documents\Games\Minesweeper\Web\ -h "Cross-Origin-Opener-Policy: same-origin" -h "Cross-Origin-Embedder-Policy: require-corp" -h "Access-Control-Allow-Origin: *" --open-browser
```
