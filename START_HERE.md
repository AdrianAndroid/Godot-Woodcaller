# Woodcaller 从这里开始

Godot 4.7.2已安装，项目节点和输入已搭好，不需要复制代码。

## 运行
1. 双击本目录 Open_Woodcaller.command 打开工程。
2. 按F5（部分Mac键盘需Fn+F5），点击“进入林地”。
3. WASD移动；玩家没有普攻，蓝色召唤物自动攻击。
4. 敌人死亡掉绿色经验球，靠近拾取。升级暂停世界，点击按钮或按1/2/3强化。
5. 敌人近身会扣血；30分钟出现最终守卫。击败它获胜，零血失败。
6. 结算可再来一局、返回主菜单或退出；成绩自动写入Godot用户目录。

画面已接入CC0像素素材：德鲁伊玩家、灰狼召唤物、史莱姆敌人、树精Boss、绿水晶经验球、深绿森林地面与红树林障碍；已有攻击/拾取/升级/胜负等8个音效与循环BGM。正面遇墙的敌人会被挡住，尚未实现绕路寻路。

## 项目入口
- 主菜单：scenes/ui/main_menu.tscn
- 游戏：scenes/game/arena.tscn
- 玩家：scenes/player/player.tscn（CharacterBody2D、AnimatedSprite2D、碰撞与Health）
- 敌人：scenes/enemies/enemy.tscn
- 召唤物：scenes/summons/summon.tscn
- Boss：scenes/bosses/forest_boss.tscn
- 全部脚本在scripts/，每个模块测试在tests/，关键进度和测试模板在Woodcaller_Project_Log.md。

## 自动测试
在项目目录运行：

```sh
python3 tests/run_tests.py
```

默认使用 /Applications/Godot.app/Contents/MacOS/Godot，可用GODOT_BIN指定引擎路径。
每组测试需返回零失败且无引擎ERROR；最新输出在tests/results/current-*.log。
测试成绩使用隔离目录，不覆盖正常游玩存档。

## 验收边界
阶段1～13的自动测试已通过（13组回归，含词条TC-020与压力TC-021）；升级已从7种词条随机三选一。
仍需人工验收：真实键盘/切窗焦点、30分钟完整游玩、数值平衡手感、Apple Silicon实机。
最新Universal测试包已含全部素材：builds/Woodcaller.app及builds/Woodcaller-macos-universal.zip（阶段14重建）。Intel独立冒烟、签名和双架构检查通过；未公证、未沙盒签名。构建与边界见EXPORT_MACOS.md。当前不要把它当作正式发行成品。

## 接力提示（给下一个Agent）
1. 先读 Woodcaller_Project_Log.md 的「当前状态」「待办清单」「已知bug与限制」与末尾阶段12～14记录。
2. 下一步主线：人工实机验收（EXPORT_MACOS.md手动清单）→ 按手感反馈做数值平衡（敌HP每300秒翻倍、刷怪最快0.4s×4只的曲线待实测确认）→ Apple Silicon验证。
3. 测试基建约定：headless下Sfx/Music跳过真实播放（假音频驱动会泄漏致ERROR）；arena.forced_choices可钉住升级选项做确定性测试；新PNG/音频须先 `--headless --import` 再跑测试。
4. 下载外部资源走代理 127.0.0.1:7897；CC0素材登记在 assets/ART_CREDITS.md。
