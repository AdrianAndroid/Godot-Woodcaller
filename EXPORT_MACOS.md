# macOS 本地测试包

## 构建

使用Godot 4.7.2标准版与完全匹配的导出模板。预设名为 `macOS Universal`，输出 `builds/Woodcaller.app`。

```sh
./tools/build_macos.command
```

脚本会导入资源、导出Release、校验本地签名、显示二进制架构并生成 `builds/Woodcaller-macos-universal.zip`。
预期架构为 `x86_64 arm64`，主入口为主菜单。

## 当前发行边界

- 这是本地测试包，使用ad-hoc签名，没有Apple开发者证书公证。
- 未发布或上传到任何服务；其他Mac可能触发Gatekeeper提示，不能等同于正式发行包。
- 当前预设未开启App Sandbox；代码使用OS.get_user_data_dir()，实际沙盒签名及容器运行仍需独立验收。
- Intel与Apple Silicon双架构存在不等同于两种机器都实测通过。
- tests目录、开发说明和启动脚本不进入游戏资源包。

## 手动验收

1. 从Finder打开.app，确认主菜单、中文及按钮完整。
2. 进入游戏，WASD移动、拾取经验、按1/2/3选择升级。
3. 切换应用后松开移动键，再返回，检查无粘键。
4. 失败后保存成绩、重新开始，再返回主菜单查看记录。
5. 关闭应用重开，确认成绩保留；在独立用户目录测试，不删除已有玩家存档。
6. 在Apple Silicon机器重复以上步骤。
7. 完整30分钟游玩并击败Boss，检查胜利、帧率、内存和数值平衡。

自动化只覆盖已记录的部分，不把待测步骤写成通过。

## 已执行结果（2026-10-25）

构建成功，严格签名校验通过，二进制含x86_64与arm64；在Intel主机从/private/tmp独立运行120帧，退出码0、无引擎错误。包约163MB，压缩包58MB。Info.plist当前最低系统声明为Intel macOS11及arm64 macOS13。其余手动步骤仍待执行。

## 已执行结果（2026-10-25，含阶段9～13素材与词条的重建）

重建成功，严格签名校验通过（ad-hoc），二进制含x86_64与arm64；压缩包解至/private/tmp独立目录运行120帧，退出码0、无引擎错误；PCK内确认包含floor/obstacle_tree贴图、dark_woods.ogg及全部8个音效（attack/enemy_die/hurt/levelup/lose/pickup/ui_click/win）。包约164MB，压缩包58MB。手动验收步骤（真实键盘/切窗、30分钟完整游玩、Apple Silicon实机）仍待执行。
