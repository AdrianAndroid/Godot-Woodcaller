#!/bin/zsh
set -eu
project_dir="${0:A:h}"
godot_bin=""
for candidate in /Applications/Godot.app/Contents/MacOS/Godot "$HOME/Applications/Godot.app/Contents/MacOS/Godot"; do
  if [[ -x "$candidate" ]]; then
    godot_bin="$candidate"
    break
  fi
done
if [[ -z "$godot_bin" ]]; then
  print '尚未找到 Godot。请将官方 Godot.app 放入 Applications（应用程序）后再次双击。'
  print '下载地址：https://godotengine.org/download/macos/'
  read '?按回车关闭窗口。'
  exit 1
fi
exec "$godot_bin" --editor --path "$project_dir"
