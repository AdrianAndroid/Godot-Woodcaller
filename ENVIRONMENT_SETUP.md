# Woodcaller 环境配置与接力文档

> 更新时间：2026-10-25（Asia/Shanghai）。供下一位接力的 Agent / 开发者快速恢复上下文。

## 一、环境现状（已完成的安装）

| 项目 | 状态 | 说明 |
| --- | --- | --- |
| Godot 编辑器 | ✅ 已安装 | **4.7.2-stable 官方标准版**，路径 `/Applications/Godot.app` |
| 安装方式 | Homebrew Cask | `brew install --cask godot`（包名 `Godot_v4.7.2-stable_macos.universal.zip`，Universal 双架构） |
| .NET / C# | ❌ 不需要 | 项目纯 GDScript，未安装 dotnet 属正常 |
| 导出模板 | ❌ 未安装 | 编辑器内运行不需要；导出 macOS .app 时再装（需与 4.7.2 严格匹配） |
| 工程引擎解析 | ✅ 已通过 | headless 加载 `project.godot` 无错误（见下方验证命令） |
| 游戏运行验收 | 部分通过 | 主场景命令行启动与截图通过；25项引擎断言通过；F5/真人键盘/真实切窗仍待验证 |

本机环境：macOS Intel x86_64（Darwin 24.6.0）。注意 Homebrew 已宣布放弃 Intel 瓶子构建，但 Godot cask 是官方 zip 分发，不受影响。

## 二、网络与代理（重要）

本机直连 GitHub release 下载极慢（约 200 KB/s，会超时）。必须走本地代理：

- **本地 Clash Verge（mihomo）常驻运行，混合代理端口：`http://127.0.0.1:7897`**（注意不是常见的 7890；7890 是 `~/bin/macmini/configs/mihomo-clash-mac.yaml` 里的客户端配置样例端口，本机实际监听 7897）。
- 验证代理可用：`curl -sI -x http://127.0.0.1:7897 https://github.com` 应返回 200（实测 <1s）。
- 涉及 GitHub/外网的命令一律加环境变量，例如：

```sh
export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897 HOMEBREW_NO_AUTO_UPDATE=1
brew install --cask godot   # 或任何需要访问 GitHub 的下载
```

- 上游代理节点信息在 `~/bin/macmini/`（阿里云 ECS mihomo，服务器 8.152.204.58:17890，见该目录 configs/ 与 docs/）。

## 三、常用命令

```sh
# 版本确认（当前输出：4.7.2.stable.official.ed1daf0bf）
/Applications/Godot.app/Contents/MacOS/Godot --version

# 无头验证工程解析（无 SCRIPT ERROR 即通过）
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaojian/code/godot-Woodcaller --quit

# 打开编辑器（也可双击项目根目录的 Open_Woodcaller.command）
/Applications/Godot.app/Contents/MacOS/Godot --editor --path /Users/zhaojian/code/godot-Woodcaller
```

## 四、本次安装中已修复的问题

`scripts/player/player.gd:45` 原调用 `Input.release_pressed_events()`，**该方法在 Godot 4 中不存在**，headless 加载时报 Parse Error。已改为失焦时逐个释放四个移动动作：

```gdscript
for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
    Input.action_release(action)
```

修复后 headless 加载无任何脚本错误。该修复已通过模拟焦点通知回归；真实窗口中“失焦不粘键”仍待验证（TC-003）。

## 五、接力者下一步（按优先级）

1. **补完真实键盘、切窗和 F5 测试**。启动脚本、命令行主场景渲染及25项程序化断言已通过；GUI 工具因 window_not_focused 未能发送键盘输入。执行 `Woodcaller_Project_Log.md` 中 TC-001（移动/速度）、TC-002（碰撞）、TC-003（失焦/信号）、TC-004（启动与动画接口）、TC-005（启动入口），把执行记录补进日志。
2. 阶段2已完成，敌人22项自动测试与玩家25项回归通过；按用户连续开发授权进入阶段3召唤物。
3. 需要打包 .app 时：下载与编辑器**完全同版本**的导出模板（4.7.2），配置 macOS Universal 导出；下载模板同样要走第二节的代理。

## 六、项目关键事实速查

- 主场景：`scenes/test/enemy_chase_test.tscn`；玩家脚本：`scripts/player/player.gd`（class_name `WoodcallerPlayer`）。
- 渲染：GL Compatibility；逻辑分辨率 640×360，窗口 1280×720，stretch=canvas_items。
- 输入动作：`move_left/move_right/move_up/move_down`（物理键位 A/D/W/S）。
- 碰撞层：layer 1 = World，layer 2 = Player；玩家 layer=2 / mask=1。
- 项目约定与测试用例：见 `Woodcaller_Project_Log.md`；新手操作说明：见 `START_HERE.md`。


## 最新覆盖说明（2026-10-25）
阶段1～8已连接且完整8组自动测试通过，阶段7解析错误已修复。
当前主场景为 scenes/ui/main_menu.tscn，游戏主体 scenes/game/arena.tscn。
统一回归：python3 tests/run_tests.py。进度以Woodcaller_Project_Log.md的当前摘要及末尾条目为准。
剩余重点为主菜单/GUI验收、失败保存重试、真实输入、长时间测试、正式素材音频和macOS Universal导出。
