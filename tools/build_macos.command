#!/bin/zsh
set -eu
project_dir="${0:A:h:h}"
godot_bin="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [[ ! -x "$godot_bin" ]]; then
  print -u2 'Godot editor not found; set GODOT_BIN.'
  exit 1
fi
mkdir -p "$project_dir/builds"
"$godot_bin" --headless --path "$project_dir" --script tools/generate_notices.gd
"$godot_bin" --headless --path "$project_dir" --editor --import --quit
"$godot_bin" --headless --path "$project_dir" --export-release 'macOS Universal' "$project_dir/builds/Woodcaller.app"
/bin/cp "$project_dir/THIRD_PARTY_NOTICES.txt" "$project_dir/builds/Woodcaller.app/Contents/Resources/THIRD_PARTY_NOTICES.txt"
/usr/bin/codesign --force --deep --sign - "$project_dir/builds/Woodcaller.app"
/usr/bin/codesign --verify --deep --strict "$project_dir/builds/Woodcaller.app"
/usr/bin/lipo -archs "$project_dir/builds/Woodcaller.app/Contents/MacOS/Woodcaller"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$project_dir/builds/Woodcaller.app" "$project_dir/builds/Woodcaller-macos-universal.zip"
print "Built: $project_dir/builds/Woodcaller-macos-universal.zip"
