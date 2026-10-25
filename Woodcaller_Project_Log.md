# Woodcaller（林地召唤者）项目日志

## 项目约定
- 引擎：Godot 4.7，GDScript 2.0；目标：macOS Intel x86_64 + Apple Silicon 通用 .app。
- 2D 俯视角召唤流幸存者肉鸽；玩家仅 WASD 移动，无普攻、无鼠标瞄准。
- 输入：move_left、move_right、move_up、move_down。
- 脚本使用 snake_case、类型标注、@export 可调参数与信号解耦；禁用 Godot 3 API。
- 存档使用 OS.get_user_data_dir() 对应的用户数据目录。
- 美术：32×32 透明 PNG，暗黑奇幻森林、低饱和硬边像素；优先适配 AnimatedSprite2D。
- 每次只开发一个模块，完成后登记实现、测试与素材，再等待指令。

## 当前状态（2026-10-25；以此摘要和末尾记录为准）
- Godot 4.7.2标准版已安装；主场景为 scenes/ui/main_menu.tscn。
- 阶段1～8代码完成；阶段9～12（像素美术、音效BGM、场地美术、词条扩展）与阶段13压力测试完成，最新13组集成回归全部通过；阶段14已重建含全部新素材的macOS Universal测试包并冒烟通过。
- 玩家只WASD移动，召唤物自动战斗；经验升级、波次、接触伤害、Boss、胜负结算与成绩存档已连接。
- 角色、经验球与场地（深绿森林地面、红树林障碍、主菜单背景）已接入CC0像素素材（ART-001～007）；音效与循环BGM已接入（AUD-001～002）。
- 阶段7独立测试的WaveDirector全局名解析问题已改为/root/WaveDirector实例引用并通过。

## 待办清单
1. 已实现：玩家移动、敌人AI、召唤物、经验三选一、波次、存档、Boss、胜负结算。
2. 主菜单流程与UI视觉验收已通过，真实键盘/焦点待补。
3. 保存失败重试与高负载/快进长局压力测试已通过（TC-021）；真实30分钟游玩、真实键盘输入与切窗焦点仍待人工验收。
4. 词条已扩展为随机三选一7种（阶段12），数值平衡待真实游玩调校；像素美术与音效/BGM已接入（ART-001～007、AUD-001～002）；像素字体未引入。
5. macOS Universal测试包已重建（含全部新素材，164MB/zip 58MB）并通过Intel独立冒烟；Apple Silicon实机、完整游玩、公证/沙盒发行待补。

## 已知bug与限制
- 当前程序化测试通过；不代表完整30分钟、真实键盘切窗、离线.app或Apple Silicon实机通过。
- 敌人/Boss直线追踪，正面遇墙不会自动绕路；敌人之间可重叠。
- 角色与经验球已接入32×32 CC0像素素材（ART-001～005）；音效与BGM已接入（AUD-001～002）；场地障碍/背景仍为几何占位，像素字体尚未引入。
- 存档记录跨局成绩，不支持中途续局；写入失败UI重试专项测试通过。
- 早期日志中的“未安装”“阶段2”等为历史事实，不代表当前状态。

## 素材清单
| 素材ID | 素材用途 | 尺寸规格 | 风格要求 | 来源类型 | 版权说明 | 导入Godot设置 |
| --- | --- | --- | --- | --- | --- | --- |
| ART-001 | 玩家（林地德鲁伊）idle/walk | 32×32 RGBA PNG×4 | 暗黑低饱和硬边像素 | OpenGameArt「Dungeon Crawl 32×32 tiles」spriggan_druid.png（派生1px浮动帧） | CC0 1.0，可商用可修改无需署名；https://opengameart.org/content/dungeon-crawl-32x32-tiles | AnimatedSprite2D，texture_filter=Nearest |
| ART-002 | 召唤物（狼）idle/walk | 32×32 RGBA PNG×4 | 同上 | 同包 monster/animals/wolf.png（派生浮动帧） | CC0 1.0，同上 | 同上 |
| ART-003 | Boss（树精林地守卫）idle/walk | 32×32 RGBA PNG×4，场景2倍显示 | 同上 | 同包 monster/fungi_plants/treant.png（派生浮动帧） | CC0 1.0，同上 | 同上；碰撞半径改为16 |
| ART-004 | 经验球（绿水晶）明暗脉冲 | 32×32 RGBA PNG×2 | 同上 | 同包 item/misc/misc_crystal_new.png（色相旋转为绿色） | CC0 1.0，同上 | AnimatedSprite2D autoplay，Nearest |
| ART-005 | 敌人（史莱姆）idle/walk | 32×32 RGBA PNG×8 | 同上 | OpenGameArt「Pixel Art Animated Slime」作者 rvros；4×4切片、降饱和降明度 | CC0 1.0；https://opengameart.org/content/pixel-art-animated-slime | AnimatedSprite2D，Nearest |
| ART-006 | 场地地面（对局与主菜单背景） | 640×360 RGBA PNG | 暗黑低饱和 | DCSS包 dungeon/floor 苔藓/沼绿/草/泥土/蓝花五瓦片固定种子拼贴后压暗 | CC0 1.0，同ART-001来源包 | Sprite2D，Nearest |
| ART-007 | 障碍物（深色红树林双树冠） | 48×80 RGBA PNG | 同上 | DCSS包 dungeon/trees/mangrove_1.png 双段拼贴压暗 | CC0 1.0，同上 | Sprite2D，Nearest；碰撞保持48×80不变 |
| AUD-001 | 攻击/敌人死亡/拾取/升级/受伤/胜/负/UI点击音效 | 44.1kHz 16bit mono WAV×8 | 复古8-bit | OpenGameArt「512 Sound Effects」作者 Juhani Junkala，原名映射见 ART_CREDITS.md | CC0 1.0；https://opengameart.org/content/512-sound-effects-8-bit-style | Sfx autoload 8路池化播放 |
| AUD-002 | 主菜单与对局BGM | OGG Vorbis 约36秒循环 | 暗黑森林氛围 | OpenGameArt「Dark Woods Loop」dark_woods_in_game.ogg 作者 beardalea | CC0 1.0；https://opengameart.org/content/dark-woods-loop | Music autoload，loop=true，-8dB |

来源包均下载至隔离暂存目录后由 tools/build_art.py 生成派生帧；完整授权文本与链接见 assets/ART_CREDITS.md。原型优先检索 CC0、免费商用、无需署名素材；引入时登记来源链接、关键词与 Nearest 过滤设置。

## 测试记录
已登记 TC-001～TC-005。2026-10-25 静态检查通过：所有场景资源路径存在、四个输入动作名称一致、启动入口通过 zsh -n。后续已完成引擎导入、TC-006 的25项断言与窗口画面检查，详见本次验收记录；不能据此认定真实窗口交互或独立 .app 验收完成。

## 进度记录
- 模块名称：项目日志初始化
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：记录项目约定、模块顺序、素材与测试登记位置；未开始功能开发。
- 新增/修改文件（脚本、场景、资源）：Woodcaller_Project_Log.md
- 依赖前置模块：无
- 已知限制、待优化点、未解决问题：尚未建立 Godot 工程；本次模块尚待确定。
- 关联测试用例编号：不适用（仅文档初始化）
- 关联素材清单编号：无

- 模块名称：阶段1｜玩家基础移动（代码已建立，验证中）
- 完成时间：2026-10-25（Asia/Shanghai；代码编写完成，运行验收待完成）
- 实现内容：创建工程、WASD 物理按键映射、归一化移动、墙体碰撞、失焦停止、移动与朝向信号；预留 idle/walk 动画；使用场景内几何调试色块，无外部美术资源。
- 新增/修改文件（脚本、场景、资源）：project.godot、scripts/player/player.gd、scenes/player/player.tscn、scenes/test/player_movement_test.tscn、.gitignore、Woodcaller_Project_Log.md
- 依赖前置模块：无
- 已知限制、待优化点、未解决问题：本机未找到 Godot；引擎解析、实际输入及 macOS 打包尚未验证；用户追加要求从零安装配置；暂无正式精灵动画。
- 关联测试用例编号：TC-001、TC-002、TC-003、TC-004（见下文）
- 关联素材清单编号：无（Polygon2D 调试图形，不是交付美术素材）

### TC-001
用例ID：TC-001
测试目标：验证输入与移动速度
前置条件：Godot 可打开 project.godot，主场景为 player_movement_test.tscn
测试步骤：F6 播放测试场景；分别按 WASD；按 W+D；松开所有键；同时按 A+D；点击鼠标。
预期结果：方向正确；轴向与斜向速度均为 120 px/s；松键停止；相反方向抵消；鼠标不触发攻击或瞄准。
失败判定标准：方向反转、斜向加速、松键漂移、鼠标触发战斗行为。
测试环境：Godot 4.7 编辑器内播放；macOS 通用 .app 离线运行（均待执行）。
调试手段：Remote Inspector 查看 velocity；斜向分量约为 ±84.85，总长度 120；检查 Input Map 的 physical_keycode。
常见报错排查方向：检查主场景路径、输入动作拼写、脚本挂载和窗口焦点。

### TC-002
用例ID：TC-002
测试目标：验证障碍与边界碰撞
前置条件：主测试场景加载成功
测试步骤：走向中央右侧矩形障碍，再走向四周边界；沿障碍斜向移动。
预期结果：不能穿越障碍与边界；可沿墙滑动。
失败判定标准：穿墙、退出区域、接触墙后不能离开。
测试环境：Godot 4.7 编辑器内播放；macOS 通用 .app 离线运行（均待执行）。
调试手段：Debug > Visible Collision Shapes；检查 Player layer=2/mask=1，World layer=1/mask=2。
常见报错排查方向：检查 CollisionShape2D 未禁用、形状尺寸、CharacterBody2D 的浮动运动模式。

### TC-003
用例ID：TC-003
测试目标：验证禁用移动、窗口失焦和信号
前置条件：主场景运行，可在编辑器查看 Remote Inspector
测试步骤：移动时切换到其他应用并松键；返回游戏；在 Remote Inspector 将 movement_enabled 设为 false，再设为 true；观察 movement_changed 与 facing_changed。
预期结果：失焦立即清零速度，返回后不会粘键；禁用移动后静止，重新启用后正常；信号仅状态变化时触发。
失败判定标准：失焦持续移动、禁用无效、每帧重复发相同状态信号。
测试环境：Godot 4.7 编辑器内播放；macOS 通用 .app 离线运行（禁用开关通过 Remote Debug 验证；均待执行）。
调试手段：在信号 emit 行设断点，查看 _has_focus、movement_enabled、velocity。
常见报错排查方向：检查应用焦点通知、窗口是否真正失焦及四个移动动作的 Input.action_release 调用。

### TC-004
用例ID：TC-004
测试目标：验证启动与动画接口
前置条件：可用 Godot 编辑器；打包测试另需匹配版本的导出模板
测试步骤：导入 project.godot 后 F5；检查 Debugger；向 AnimatedSprite2D 的 idle/walk 各加入测试帧并隐藏 DebugBody，移动与停止；离线打开导出的 .app 重复 TC-001/002。
预期结果：默认几何角色可见，无脚本错误；有帧时播放对应动画、左右翻转；.app 可独立运行。
失败判定标准：导入或脚本解析报错、场景缺失、动画缺失导致崩溃、.app 无法启动。
测试环境：Godot 4.7 编辑器内播放；macOS 通用 .app 离线运行（均待执行）。
调试手段：Output/Debugger；检查 SpriteFrames 动画名称与帧数、导出日志及应用架构。
常见报错排查方向：版本不匹配、资源路径错误、导出模板缺失、macOS 应用权限与签名。


- 模块名称：阶段1配套｜新手环境配置与启动入口
- 完成时间：2026-10-25（Asia/Shanghai；工程配置完成，编辑器安装受阻）
- 实现内容：核实官方 4.7.2 macOS Universal 标准版；创建自动定位 Godot 的双击启动入口与从零操作说明；完成资源引用、输入名称和 shell 语法静态检查；尝试官方 GitHub 和镜像下载失败，内置浏览器触发下载但未确认文件落地。
- 新增/修改文件（脚本、场景、资源）：Open_Woodcaller.command、START_HERE.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1工程文件；运行入口依赖已安装的 Godot.app
- 已知限制、待优化点、未解决问题：Godot 未安装成功；未执行 Godot 解析和实际游戏测试；未安装导出模板；未创建或验证 macOS 通用游戏包。browser-act CLI 不可用，下载改用内置浏览器；未修改系统安全设置。
- 关联测试用例编号：TC-005；TC-001～TC-004 待安装后执行
- 关联素材清单编号：无

- 模块名称：环境安装｜Godot 4.7.2 编辑器落地与脚本修复
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：通过 Homebrew Cask 安装官方 Godot 4.7.2-stable（Universal）至 /Applications/Godot.app；本机直连 GitHub 仅约 200 KB/s，改用本地 Clash Verge 代理（127.0.0.1:7897）后完成；headless 加载工程发现 player.gd 调用 Godot 4 不存在的 Input.release_pressed_events() 报解析错误，已改为失焦时逐个释放四个移动动作，修复后 headless 解析零错误；编写 ENVIRONMENT_SETUP.md 接力文档。
- 新增/修改文件（脚本、场景、资源）：scripts/player/player.gd、ENVIRONMENT_SETUP.md、START_HERE.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1工程文件、Open_Woodcaller.command
- 已知限制、待优化点、未解决问题：编辑器内实际运行（F5）与 TC-001～TC-005 全部未执行；导出模板未安装；Intel 平台 Homebrew 已停止瓶子支持（不影响 cask 安装）。
- 关联测试用例编号：为 TC-001～TC-005 提供执行前提
- 关联素材清单编号：无

### TC-005
用例ID：TC-005
测试目标：验证初学者能从启动入口打开工程
前置条件：官方 Godot 4.7.2 已放入 /Applications/Godot.app 或用户 Applications/Godot.app
测试步骤：双击 Open_Woodcaller.command；确认打开 Woodcaller 编辑器；点击右上角播放按钮；检查角色显示并完成 TC-001。
预期结果：无需手工搭建节点即可运行主场景；缺少编辑器时入口显示明确安装提示。
失败判定标准：找不到已安装的标准路径编辑器、打开错误项目、主场景缺失。
测试环境：macOS Finder 与 Godot 4.7.2 编辑器；独立 .app 不使用该开发入口，其运行验收见 TC-004。
调试手段：终端输出、zsh -n Open_Woodcaller.command、Godot Output/Debugger。
常见报错排查方向：Godot.app 位置不正确、启动入口执行权限、Godot 首次启动系统提示。
执行记录：启动脚本语法、资源路径及输入名称静态检查通过；真实启动未执行。

- 模块名称：阶段1｜可重复引擎测试
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：新增真实物理帧测试，注入物理按键事件验证四向速度、斜向归一化、松键、相反方向、障碍与四边界、沿墙滑动、移动开关、状态信号、模拟焦点通知、idle/walk 动画与翻转；首轮全部通过（0 failures）。
- 新增/修改文件（脚本、场景、资源）：tests/player_movement_test.gd、Woodcaller_Project_Log.md
- 依赖前置模块：Godot 4.7.2、阶段1场景与玩家脚本
- 已知限制、待优化点、未解决问题：无头测试的焦点通知为模拟，不代表 macOS 实际切窗验证；沙盒运行时系统证书读取报错，需非沙盒复核；UI 与独立 .app 测试仍待执行。
- 关联测试用例编号：TC-001～TC-004（程序化覆盖）；TC-006
- 关联素材清单编号：无（测试纹理仅运行时创建，不保存美术资源）

### TC-006
用例ID：TC-006
测试目标：可重复回归阶段1移动与物理、动画接口
前置条件：Godot 4.7.2 已安装，项目资源已导入
测试步骤：在项目目录执行 /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/player_movement_test.gd；查看 PASS/FAIL 与退出码。
预期结果：全部 PASS，RESULT: 0 failure(s)，退出码 0。
失败判定标准：任一 FAIL、脚本错误或非零退出码。
测试环境：macOS Intel、Godot 4.7.2 headless；编辑器 GUI 与独立 macOS .app 另按 TC-001～TC-005 验证，不能用此用例替代。
调试手段：标准输出、--log-file 指定日志、在失败断言前输出 position/velocity。
常见报错排查方向：项目未导入、输入动作变更、碰撞尺寸或速度调整导致测试基准需要评审；缓存/证书权限问题需区分环境和代码错误。


- 模块名称：阶段1｜运行验收与文档同步
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：Godot 4.7.2 正常权限下工程导入通过；TC-006 共25项断言全部通过，退出码0且无引擎错误。通过 Open_Woodcaller.command 打开正确工程；通过 Godot 命令行运行主场景，截图确认文字、角色、障碍与场地显示正确，Intel UHD 630 OpenGL 4.1 渲染启动正常。同步三份文档当前状态，保留历史进度条目。
- 新增/修改文件（脚本、场景、资源）：Woodcaller_Project_Log.md、START_HERE.md、ENVIRONMENT_SETUP.md、tests/results/stage1-headless.log、tests/results/stage1-gui.log、tests/results/stage1-window.png；测试脚本自动生成的 .gd.uid 为 Godot 资源标识。
- 依赖前置模块：阶段1玩家移动、Godot 4.7.2、computer-use 窗口观察能力
- 已知限制、待优化点、未解决问题：窗口工具返回 window_not_focused，恢复窗口后仍无法输入；未把失败的 F5 尝试算作通过。真实 WASD 按键、鼠标无攻击与 macOS 切窗尚待人工验收；无头注入事件和焦点通知不能替代这些步骤。导出模板和独立 .app 未验证，未开始阶段2。
- 关联测试用例编号：TC-001/002/003/004 程序化子项通过；TC-004 实际窗口渲染通过；TC-005 启动脚本打开正确工程通过（Finder 双击/F5 流程未完整验证）；TC-006 全部通过
- 关联素材清单编号：无（stage1-window.png 为验收截图，不作为游戏素材导入）

### 本轮验收结论
| 项目 | 结果 |
| --- | --- |
| TC-001 四向/斜向速度、松键、反向抵消 | 引擎注入物理键事件通过；真人键盘与鼠标部分待验收 |
| TC-002 障碍、四边界、沿墙滑动 | 真实物理帧程序化测试通过 |
| TC-003 移动开关、信号与焦点 | 开关/信号通过；焦点通知模拟通过，真实切窗待验收 |
| TC-004 启动、动画 | 主场景窗口截图通过；动画测试纹理通过；正式美术与 .app 未测试 |
| TC-005 新手启动 | 启动脚本打开正确工程通过；Finder 双击/F5 未完整验证 |
| TC-006 自动回归 | 25 PASS，0 FAIL，正常权限运行无引擎错误 |

测试日志：tests/results/stage1-headless.log；窗口截图：tests/results/stage1-window.png。
下一步：用户在已打开的 Woodcaller (DEBUG) 游戏窗口点击场地，按 WASD、松键、尝试走向边界，移动时切换应用并松键再返回。确认无异常后记录真实交互结果；按用户下一次指令进入阶段2。

- 模块名称：阶段2｜敌人直线追踪 AI（实现完成，测试中）
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：按 player 组自动获取目标；65 px/s 等速追踪；20 px 停止距离与末帧限速避免越过目标；目标失效停止、每0.25秒重试；移动开关、目标/移动状态信号；idle/walk 动画与左右翻转；敌人仅碰撞 World。主场景改为三敌人追踪演示，阶段1独立场景保留。
- 新增/修改文件（脚本、场景、资源）：scripts/enemies/enemy.gd、scenes/enemies/enemy.tscn、scenes/test/enemy_chase_test.tscn、project.godot、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1玩家及 player 组、World 碰撞层、Godot 4.7.2
- 已知限制、待优化点、未解决问题：直线追踪会被正面墙体挡住，不自动绕路；敌人可互相重叠，暂不碰撞玩家、不伤害、不生成波次；暂无正式美术；阶段1真实交互及打包验收仍未补完，用户已明确授权阶段2。
- 关联测试用例编号：TC-007～TC-009（下文补充）
- 关联素材清单编号：无（场景内 Polygon2D 调试图形，未引入游戏美术资源）

### TC-007
用例ID：TC-007
测试目标：验证敌人等速追踪和近身停止
前置条件：Godot 4.7.2；enemy_chase_test.tscn；玩家在 player 组，敌人挂载 enemy.gd
测试步骤：F5 运行；用 WASD 改变位置，观察左侧与下方敌人；停止移动等敌人靠近；在 Remote Inspector 将 Move Speed 提高，观察近身表现。程序化覆盖运行 tests/enemy_chase_test.gd。
预期结果：默认65 px/s向玩家追踪，斜向不加速；距离20 px时停下；玩家离开后继续追踪；高速接近不越过停止半径；完全重合不出现无效坐标。
失败判定标准：方向反了、斜向加速、来回越过玩家、坐标出现 NaN 或脚本错误。
测试环境：Godot 4.7.2 编辑器播放；macOS Universal .app 离线包（打包环境待导出阶段执行）；本轮自动化环境为 macOS Intel headless。
调试手段：Remote Inspector 检查 global_position、velocity、Move Speed、Stop Distance；Output 查看断言。
常见报错排查方向：player 组拼写、根节点是否 Node2D、速度/停止距离参数、目标是否被墙挡住。

### TC-008
用例ID：TC-008
测试目标：验证目标生命周期、移动开关与信号
前置条件：敌人场景可实例化；测试脚本可运行
测试步骤：执行 Godot --headless --path . --script tests/enemy_chase_test.gd；覆盖先无玩家后加入、玩家销毁后重新加入、禁用/启用追踪。编辑器中也可单独 F6 运行 enemy.tscn 验证无玩家静止，再 F5 运行演示场景切换敌人的 Movement Enabled。
预期结果：无目标静止；在搜索间隔内发现新玩家；旧目标释放后不访问已释放对象；target_changed 仅获取/丢失时触发，movement_changed 仅移动状态变化时触发。
失败判定标准：无目标崩溃、访问 freed instance、不断发相同信号、禁用后移动或重新启用无反应。
测试环境：Godot 4.7.2 编辑器；macOS Universal .app 离线包（待执行，可通过 Remote Debug 检查开关）；自动测试为 macOS Intel headless。
调试手段：信号 emit 行断点、Remote Inspector、测试输出；关注 _target 与 _search_remaining。
常见报错排查方向：目标没有加入 player 组、目标排队删除、不同场景树、目标组误配置。

### TC-009
用例ID：TC-009
测试目标：验证碰撞、动画接口和三敌人演示集成
前置条件：主场景 enemy_chase_test.tscn；World layer 1，Player layer 2，Enemy layer 3；敌人 mask=1
测试步骤：F5 运行，观察墙右侧敌人被挡住；玩家沿障碍上下移动，观察敌人沿墙滑动；运行 enemy_chase_test.gd 自动测试边界、idle/walk与翻转。添加正式帧后隐藏敌人 DebugBody，重复追踪与停止操作。
预期结果：不穿墙，不越边界；正面遇墙停住，斜向时可沿墙滑动；移动/停止对应walk/idle；朝左翻转、朝右恢复；空动画资源也不报错；默认场景包含三只敌人。
失败判定标准：穿墙、脚本错误、动画状态错误、默认场景加载失败。
测试环境：Godot 4.7.2 编辑器；macOS Universal .app 离线包（待执行）；本轮程序化测试使用真实物理帧与临时运行时测试纹理。
调试手段：Debug > Visible Collision Shapes；检查 collision_layer/collision_mask；检查 AnimatedSprite2D 的 SpriteFrames 与 Output。
常见报错排查方向：Enemy层的数值是4（第3位），mask=1只检查世界；正面墙挡住是本阶段预期，尚未实现导航；敌人相互重叠及无伤害也属当前设计。

- 模块名称：阶段2｜测试脚本与测试用例
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：添加22项真实物理帧断言，覆盖追踪、目标生命周期、碰撞、动画和演示场景；首轮22项全部通过，退出码0，无引擎错误；补齐 TC-007～TC-009 的编辑器与打包验证步骤。
- 新增/修改文件（脚本、场景、资源）：tests/enemy_chase_test.gd、Woodcaller_Project_Log.md；引擎可生成对应 .gd.uid
- 依赖前置模块：阶段2敌人模块与阶段1测试场景
- 已知限制、待优化点、未解决问题：程序化测试不代表人工键盘或独立 .app 验收；正式帧尚未导入。
- 关联测试用例编号：TC-007、TC-008、TC-009
- 关联素材清单编号：无（临时测试纹理不保存为美术资源）


- 模块名称：阶段2｜交付及连续开发授权
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：敌人22项、玩家25项断言通过；图形模式启动正常，使用 --quit-after 120 完成短运行；F5默认入口改为三敌人演示。用户授权不再等待模块间确认，连续按顺序推进，每个关键节点写日志，至五小时额度限制。
- 新增/修改文件（脚本、场景、资源）：tests/results/stage2-headless.log、tests/results/stage2-player-regression.log、tests/results/stage2-gui.log、START_HERE.md、ENVIRONMENT_SETUP.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1、阶段2
- 已知限制、待优化点、未解决问题：图形启动日志不能代替画面与实际操作验收；未实现绕障、伤害和波次；打包尚未验证。
- 关联测试用例编号：TC-006～TC-009
- 关联素材清单编号：无

- 模块名称：阶段3｜召唤物与敌人生命值
- 完成时间：2026-10-25（Asia/Shanghai；实现完成，测试中）
- 实现内容：独立召唤物场景，围绕玩家移动，自动攻击范围内最近且无墙遮挡的敌人，带攻击间隔；通用生命组件与一次性死亡信号；敌人死亡发 defeated(position, experience) 后移除，供后续经验系统订阅；玩家仍无攻击。
- 新增/修改文件（脚本、场景、资源）：scripts/combat/health.gd、scripts/summons/summon.gd、scenes/summons/summon.tscn、scripts/enemies/enemy.gd、scenes/enemies/enemy.tscn、scenes/test/summon_test.tscn、project.godot
- 依赖前置模块：阶段1、阶段2
- 已知限制、待优化点、未解决问题：直接命中，无弹道/攻击特效；小范围环绕可能穿过墙体，但攻击射线检查World；几何占位图形；无正式美术。
- 关联测试用例编号：TC-010
- 关联素材清单编号：无

### TC-010
用例ID：TC-010
测试目标：验证召唤物自动攻击、冷却、遮挡及敌人死亡
前置条件：阶段3场景与生命组件已导入
测试步骤：运行 tests/summon_test.gd；编辑器F5运行 summon_test.tscn，靠近敌人等待自动击杀；隔墙接近敌人再观察。
预期结果：召唤物保持30px环绕，默认每0.7秒造成10伤害，30HP敌人三击死亡且死亡信号一次；墙挡住攻击，范围外不攻击；玩家消失不崩溃。
失败判定标准：玩家主动攻击、冷却失效、隔墙命中、重复死亡、目标释放报错。
测试环境：Godot4.7.2编辑器；macOS .app离线包（待打包）；本轮为Intel headless自动化。
调试手段：attacked/defeated信号断点、Health.current_health、攻击射线碰撞mask、测试日志。
常见报错排查方向：enemy组、Health子节点、World层和射线、攻击范围。
执行记录：8项断言通过；日志 tests/results/stage3-headless.log。

- 模块名称：阶段3｜验证收尾
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：召唤物8项断言通过，工程导入无脚本错误；测试输出目录加.gdignore避免截图被导入游戏。
- 新增/修改文件（脚本、场景、资源）：tests/summon_test.gd、tests/results/stage3-headless.log、tests/results/.gdignore、Woodcaller_Project_Log.md
- 依赖前置模块：阶段3
- 已知限制、待优化点、未解决问题：手动及打包测试待执行；后续进行阶段4。
- 关联测试用例编号：TC-010
- 关联素材清单编号：无

- 模块名称：阶段4｜经验与三选一
- 完成时间：2026-10-25（Asia/Shanghai；测试中）
- 实现内容：死亡信号生成经验球；Area2D只拾取玩家且一次性领取；升级需求10起每级+5；跨级队列；升级暂停世界、UI始终处理；按钮/数字1～3选择灵力、移速或增召唤，召唤上限5后改为减攻击间隔；新召唤继承已有加成。
- 新增/修改文件（脚本、场景、资源）：scripts/progression/*、scripts/ui/run_ui.gd、scripts/game/arena.gd、scenes/game/arena.tscn、scenes/pickups/experience_orb.tscn、project.godot
- 依赖前置模块：阶段1～3
- 已知限制、待优化点、未解决问题：固定三个词条，尚无词条稀有度；经验球暂无吸附动画；后续阶段5补波次。
- 关联测试用例编号：TC-011
- 关联素材清单编号：无（几何占位）

### TC-011
用例ID：TC-011
测试目标：验证经验球拾取与跨级三选一
前置条件：Arena场景、Progression与RunUI已导入
测试步骤：运行 tests/progression_test.gd；F5游玩，等召唤物击杀后走向绿色经验球；升级时点击一个按钮或按1/2/3；连续跨级依次选择。
预期结果：经验只领取一次；无效负经验忽略；每次升级消费对应经验，余量保留；世界暂停UI可用，全部选择完成才恢复；新召唤继承灵力；重复点击无重复奖励。
失败判定标准：经验重复、暂停卡死、跨级少选、未升级也能领强化。
测试环境：Godot4.7.2编辑器；macOS .app离线包（后续导出验证）；Intel headless本轮通过12项。
调试手段：pending_levels、Progression.level/experience、SceneTree.paused、按钮pressed信号、经验球body_entered。
常见报错排查方向：UI process_mode必须ALWAYS；orb mask=2；死亡信号重复连接；召唤组和强化继承。
执行记录：12 PASS，0 FAIL，日志 tests/results/stage4-headless.log；真实UI点击与打包待验证。

- 模块名称：阶段4｜测试收尾
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：12项回归通过，跨级选择与暂停恢复通过；当前主场景Arena。
- 新增/修改文件（脚本、场景、资源）：tests/progression_test.gd、tests/results/stage4-headless.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段4
- 已知限制、待优化点、未解决问题：手动GUI及打包待验收。
- 关联测试用例编号：TC-011
- 关联素材清单编号：无

- 模块名称：阶段5｜波次管理与生存伤害
- 完成时间：2026-10-25（Asia/Shanghai；测试中）
- 实现内容：Autoload WaveDirector；按存活时间增强血量/速度、加快频率并增加批量，场上60只上限；边缘随机刷怪且避墙/避玩家；30分钟只触发一次boss_due并停止普通波次。玩家100生命、0.8秒无敌间隔；敌人24px内每秒接触伤害，射线阻止隔墙伤害；HUD显示血量/时间；玩家死亡暂停等待阶段8界面。
- 新增/修改文件（脚本、场景、资源）：scripts/autoload/wave_director.gd、scripts/player/player.gd、scenes/player/player.tscn、scripts/enemies/enemy.gd、scripts/game/arena.gd、scripts/ui/run_ui.gd、project.godot
- 依赖前置模块：阶段1～4
- 已知限制、待优化点、未解决问题：数值为原型；Boss由阶段7订阅；失败UI由阶段8实现；无自动寻路。
- 关联测试用例编号：TC-012
- 关联素材清单编号：无

### TC-012
用例ID：TC-012
测试目标：验证波次、安全刷怪、终局时间和接触伤害
前置条件：WaveDirector为Autoload；玩家Health存在
测试步骤：运行 tests/waves_test.gd；编辑器F5观察计时/刷怪与受伤。可在Remote将elapsed设为1799测试阈值；设置enemy_cap=1检查上限。
预期结果：刷怪距玩家≥110px且不嵌墙，数量≤上限，后期血量/速度增长；1800秒boss_due一次且停止普通刷怪；玩家受伤后0.8秒内不再次扣血；重开计时归零。
失败判定标准：无限刷怪、重复终局事件、秒伤叠加突破无敌间隔、重开保留旧计时。
测试环境：Godot4.7.2编辑器、macOS .app离线（后续）；本轮Intel headless通过8项。
调试手段：active/elapsed/enemy_cap、enemy组计数、boss_due断点、Health.current_health。
常见报错排查方向：Autoload配置、arena_bounds、碰撞查询、场景退出时stop_run。
执行记录：8 PASS，0 FAIL；tests/results/stage5-headless.log。

- 模块名称：阶段5｜验证完成
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：8项自动回归通过；进入阶段6持久存档。
- 新增/修改文件（脚本、场景、资源）：tests/waves_test.gd、tests/results/stage5-headless.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段5
- 已知限制、待优化点、未解决问题：完整30分钟耐久测试未执行；阈值通过加速测试覆盖。
- 关联测试用例编号：TC-012
- 关联素材清单编号：无

- 模块名称：阶段6｜macOS用户目录存档
- 完成时间：2026-10-25（Asia/Shanghai；测试中）
- 实现内容：SaveStore Autoload，OS.get_user_data_dir()/progress.json；保存局数/胜场/最长时间/最高等级；schema验证，损坏主档回退备份，无有效档回默认；临时文件写入后重命名提交、有效主档轮换.bak；写入失败信号；阶段8接结算保存。
- 新增/修改文件（脚本、场景、资源）：scripts/autoload/save_store.gd、project.godot、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～5（结算数据来源在阶段8接入）
- 已知限制、待优化点、未解决问题：本阶段保存跨局记录，不提供中途续局；无云同步；测试使用隔离目录不修改玩家真实存档。
- 关联测试用例编号：TC-013
- 关联素材清单编号：无

### TC-013
用例ID：TC-013
测试目标：验证持久记录与损坏恢复
前置条件：SaveStore Autoload；允许写Godot用户目录
测试步骤：运行 tests/save_test.gd，依次首次加载、胜利写入、失败写入、重新加载、故意损坏测试主档、备份恢复、再写入与拒绝无效结果。
预期结果：默认值正确，历史最大值保留，损坏主档回退上次有效备份，写入失败不更改内存记录；不使用工程相对路径。
失败判定标准：解析崩溃、覆盖真实存档、最大值降低、写入失败伪报成功。
测试环境：Godot4.7.2编辑器/Intel headless；macOS .app离线用户目录（后续导出验证）。
调试手段：get_save_path、save_failed信号、文件大小与version字段、FileAccess错误码。
常见报错排查方向：目录权限、磁盘空间、非法JSON、字段类型/数值范围与schema版本。
执行记录：9项断言通过，故意损坏文件可安静回退；隔离测试目录已清理。日志 tests/results/stage6-headless.log。

- 模块名称：阶段6｜验证完成
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：9项测试通过；修正JSON解析以避免预期损坏产生引擎ERROR；限制异常大数值；不修改真实存档。
- 新增/修改文件（脚本、场景、资源）：tests/save_test.gd、scripts/autoload/save_store.gd、tests/results/stage6-headless.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段6
- 已知限制、待优化点、未解决问题：未做断电故障注入；仍需macOS导出包确认用户目录行为。
- 关联测试用例编号：TC-013
- 关联素材清单编号：无

- 模块名称：阶段7｜最终BOSS
- 完成时间：2026-10-25（Asia/Shanghai；测试中）
- 实现内容：1800秒在离玩家最远的安全角落生成唯一林地守卫；1200生命、追踪与接触伤害；半血加速狂暴；每轮地面标记玩家旧位置，1.2秒后42px范围脉冲，玩家可离开预警躲避；HUD血量；死亡发run_won供阶段8结算。
- 新增/修改文件（脚本、场景、资源）：scripts/bosses/forest_boss.gd、scenes/bosses/forest_boss.tscn、scripts/game/arena.gd、scripts/ui/run_ui.gd、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～6
- 已知限制、待优化点、未解决问题：Boss仍直线追踪；预警为几何调试图；数值待完整30分钟平衡测试。
- 关联测试用例编号：TC-014
- 关联素材清单编号：无

### TC-014
用例ID：TC-014
测试目标：验证最终Boss唯一性、狂暴、预警攻击和死亡信号
前置条件：阶段7场景已导入，WaveDirector已配置Autoload
测试步骤：运行 tests/boss_test.gd；编辑器将WaveDirector.elapsed设为1799触发Boss，观察预警并移动离开，降低Boss至半血后击杀。
预期结果：只生成一个Boss，初始1200HP，半血只触发一次狂暴；预警后留在范围内扣20生命，离开范围免伤；死亡胜利信号仅一次。
失败判定标准：重复Boss/信号、无预警伤害、躲避仍受伤、脚本解析失败。
测试环境：Godot4.7.2编辑器与macOS .app离线包（手动/打包待执行）；Intel headless本轮7项通过。
调试手段：boss组、is_enraged、_warning_remaining、Health和run_won信号。
常见报错排查方向：--script模式下Autoload全局名称解析时序；通过/root/WaveDirector获取实例。
执行记录：修复arena.gd的WaveDirector解析错误后7 PASS，0 FAIL；tests/results/stage7-headless.log。

- 模块名称：阶段7｜恢复与验证收尾
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：额度恢复后修复独立测试编译的Autoload名称问题，运行7项Boss测试全部通过；先前额度限制阻止的修复此前确实未执行。
- 新增/修改文件（脚本、场景、资源）：scripts/game/arena.gd、tests/boss_test.gd、tests/results/stage7-headless.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段7
- 已知限制、待优化点、未解决问题：实际UI和完整时长测试待补；OpenViking经验检索因嵌入模型未开通失败，不影响本地开发，未更改外部服务配置。
- 关联测试用例编号：TC-014
- 关联素材清单编号：无

- 模块名称：阶段8｜胜负结算与重开
- 完成时间：2026-10-25（Asia/Shanghai；实现完成，测试中）
- 实现内容：玩家死亡失败、Boss死亡胜利；统一幂等结算，暂停并清空升级队列，记录存活时间/等级/击杀数；调用SaveStore保存一次成绩，失败允许重试；结果面板提供再来一局与退出；重开使用新的Arena场景；同时死亡时玩家零血优先判负。
- 新增/修改文件（脚本、场景、资源）：scripts/game/arena.gd、scripts/ui/run_ui.gd、tests/boss_test.gd、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～7、SaveStore
- 已知限制、待优化点、未解决问题：真实UI、重新开始、保存失败路径与全量回归尚待本轮测试；无主菜单。
- 关联测试用例编号：TC-015
- 关联素材清单编号：无

### TC-015
用例ID：TC-015
测试目标：验证胜负结算、存档幂等与场景重开
前置条件：Arena、RunUI、SaveStore、WaveDirector可加载
测试步骤：运行 tests/game_end_test.gd；编辑器游玩至零血查看失败；测试中触发Boss并击杀查看胜利；升级时死亡；点击再来一局。
预期结果：胜负只结算一次并保存一次；结果覆盖升级选择，世界暂停但结果按钮可用；重开计时/血量/等级/召唤物归初始，旧实体清除；退出Arena解除暂停。
失败判定标准：重复记录、胜负冲突、旧升级仍领奖、重开保留暂停或旧实体。
测试环境：Godot4.7.2编辑器与macOS通用.app（手动/打包待执行）；Intel headless本轮13项通过，使用隔离存档。
调试手段：run_ended/_result_saved、SaveStore.data、SceneTree.paused、run_finished信号、current_scene。
常见报错排查方向：结果UI需ALWAYS处理；重开延迟切场景；回调幂等保护；存档必须使用用户目录。
执行记录：13 PASS，0 FAIL；tests/results/stage8-headless.log。

- 模块名称：阶段8｜自动验收完成
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：13项测试通过，实际执行change_scene_to_file验证重开；记录胜负与重复事件均正确；新增全量测试入口，每个测试独立进程并带35秒超时，要求RESULT及无ERROR。
- 新增/修改文件（脚本、场景、资源）：tests/game_end_test.gd、tests/run_tests.py、tests/results/stage8-headless.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8
- 已知限制、待优化点、未解决问题：保存失败重试路径尚需测试；UI视觉/实际键盘、完整30分钟、导出验证待完成；当前进入全量回归。
- 关联测试用例编号：TC-015
- 关联素材清单编号：无

- 模块名称：阶段1～8｜全量回归
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：执行 python3 tests/run_tests.py，8组全部通过；每组独立引擎进程且验证无ERROR与零失败结果。
- 新增/修改文件（脚本、场景、资源）：tests/results/current-*.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8
- 已知限制、待优化点、未解决问题：不等同于GUI、完整30分钟或Apple Silicon实机验收；正式美术/音效未完成。
- 关联测试用例编号：TC-001～TC-015
- 关联素材清单编号：无

- 模块名称：附加模块｜主菜单
- 完成时间：2026-10-25（Asia/Shanghai；测试中）
- 实现内容：F5入口改为主菜单，显示操作提示、胜场/局数/最长存活/最高等级；进入林地和退出；结果面板增加返回主菜单；界面按640×360逻辑画布布局。
- 新增/修改文件（脚本、场景、资源）：scripts/ui/main_menu.gd、scenes/ui/main_menu.tscn、scripts/ui/run_ui.gd、scripts/game/arena.gd、project.godot
- 依赖前置模块：阶段1～8、SaveStore
- 已知限制、待优化点、未解决问题：无音频设置、正式像素字体及背景美术；需GUI布局验证。
- 关联测试用例编号：TC-016
- 关联素材清单编号：无

### TC-016
用例ID：TC-016
测试目标：验证主菜单完整流程及实际GUI布局
前置条件：主场景main_menu.tscn；SaveStore与WaveDirector已注册
测试步骤：运行 tests/main_menu_test.gd；加 -- --capture-ui 在真实图形模式保存四张截图；通过开始按钮进入，触发升级/结算，返回主菜单检查成绩；编辑器F5后可用鼠标或键盘焦点确认。
预期结果：中文可读且无裁切；重复开始不重复载入；结算返回菜单解除暂停，成绩同步。
失败判定标准：缺字、按钮超出画布、切场景失败、暂停未清、成绩不更新。
测试环境：Godot4.7.2 Intel OpenGL真实图形模式6项通过；macOS导出包待验收。
调试手段：tests/results/ui-menu.png、ui-arena.png、ui-upgrade.png、ui-result.png，scene_changed与current_scene。
常见报错排查方向：逻辑画布尺寸、容器最小高度、中文fallback字体、Autoload与场景路径。
执行记录：6 PASS，0 FAIL；已查看menu/upgrade/result截图，文字和按钮布局无裁切。未用此测试声称真人点击或键盘焦点通过。

- 模块名称：附加主菜单｜图形验收完成
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：真实OpenGL下菜单→游戏→升级→结算→菜单6项通过；截图目视检查中文和按钮；统一更新START_HERE与日志当前摘要。
- 新增/修改文件（脚本、场景、资源）：tests/main_menu_test.gd、tests/run_tests.py、tests/results/ui-*.png、tests/results/main-menu-graphics.log、START_HERE.md、ENVIRONMENT_SETUP.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、主菜单
- 已知限制、待优化点、未解决问题：视觉仍为占位，缺少正式素材与音频；保存失败专项回归追加测试中。
- 关联测试用例编号：TC-016、TC-015
- 关联素材清单编号：无（截图为测试证据，不作为游戏资源）

- 模块名称：存档失败回归补充
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：在隔离存档目录的.tmp位置创建目录，真实模拟FileAccess写入失败；结果UI提示重试，内存成绩不变；恢复路径后重试成功且不重复计分。TC-015扩大到15项全部通过，预期WARNING已确认。
- 新增/修改文件（脚本、场景、资源）：tests/game_end_test.gd、Woodcaller_Project_Log.md
- 依赖前置模块：阶段6、阶段8
- 已知限制、待优化点、未解决问题：不代表真实磁盘断电一致性测试。
- 关联测试用例编号：TC-015
- 关联素材清单编号：无

- 模块名称：macOS导出配置（准备中）
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：添加macOS Universal预设，0.1.0，org.woodcaller.game，输出builds/Woodcaller.app；本地ad-hoc签名、不公证，排除tests和开发文档；开始获取官方4.7.2匹配模板。
- 新增/修改文件（脚本、场景、资源）：export_presets.cfg、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、主菜单、官方匹配版本导出模板
- 已知限制、待优化点、未解决问题：尚未生成包；未声明已沙盒签名或对外发布；Apple Silicon需另外实机验证；模板来源https://godotengine.org/download/archive/4.7.2-stable/。
- 关联测试用例编号：TC-017（导出后补完整结果）
- 关联素材清单编号：无

- 模块名称：导出前回归与构建脚本
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：9组当前集成测试全部通过；主菜单与存档失败恢复纳入统一回归；新增可重复导出脚本及发行边界说明。
- 新增/修改文件（脚本、场景、资源）：tools/build_macos.command、EXPORT_MACOS.md、tests/results/current-*.log、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、主菜单
- 已知限制、待优化点、未解决问题：官方模板仍下载中；当前预设为本地ad-hoc签名，不是沙盒/公证发行；Apple Silicon实机与完整时长验收待补。
- 关联测试用例编号：TC-001～TC-017
- 关联素材清单编号：无

- 模块名称：macOS导出｜模板安装与配置修复
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：官方镜像下载完成，仅安装匹配4.7.2.stable的macos.zip与version.txt，读取时校验ZIP CRC；首轮导出发现Universal强制要求ETC2/ASTC导入，已启用；构建时生成Godot及依赖许可证文本并随包携带，排除开发工具目录。
- 新增/修改文件（脚本、场景、资源）：project.godot、export_presets.cfg、tools/build_macos.command、tools/generate_notices.gd、THIRD_PARTY_NOTICES.txt（构建生成）、Woodcaller_Project_Log.md
- 依赖前置模块：官方模板、macOS导出预设
- 已知限制、待优化点、未解决问题：首轮导出失败不算完成，正在重试；本地签名仍非公证发行。
- 关联测试用例编号：TC-017
- 关联素材清单编号：无

### TC-017
用例ID：TC-017
测试目标：验证macOS Universal导出与独立启动
前置条件：Godot4.7.2及同版本macos.zip模板、codesign与lipo
测试步骤：运行 tools/build_macos.command；codesign --verify --deep --strict；lipo -archs；从/private/tmp执行导出.app内二进制且不传项目路径，--quit-after 120；另在Intel/Apple Silicon通过Finder打开并手动游玩。
预期结果：导出成功，签名有效，架构x86_64与arm64，无源码目录依赖，启动无引擎错误，菜单可加载。
失败判定标准：导出失败、缺架构、签名无效、资源缺失/脚本错误、用户目录不可用。
测试环境：本轮macOS Intel，Godot4.7.2 release模板；Apple Silicon实机、Finder和沙盒发行尚待执行。
调试手段：tests/results/macos-build.log、macos-package-smoke.log、Info.plist、codesign、lipo。
常见报错排查方向：模板版本、ETC2/ASTC导入开关、许可证修改后需重新签名、Gatekeeper公证与本地ad-hoc区别。
执行记录：导出成功，codesign严格验证通过，lipo显示x86_64 arm64；在/private/tmp独立启动120帧退出码0、无引擎ERROR。包163MB，zip约58MB。实际Info.plist最低系统为Intel macOS11、arm64 macOS13；未声称更低系统兼容。

- 模块名称：macOS Universal｜首个本地测试包
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：生成builds/Woodcaller.app及builds/Woodcaller-macos-universal.zip；包含Godot与第三方许可；完成签名、双架构和Intel独立图形启动检查。
- 新增/修改文件（脚本、场景、资源）：builds/Woodcaller.app、builds/Woodcaller-macos-universal.zip、THIRD_PARTY_NOTICES.txt、tests/results/macos-build.log、tests/results/macos-package-smoke.log、EXPORT_MACOS.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、主菜单、匹配官方模板
- 已知限制、待优化点、未解决问题：本地ad-hoc，未公证、未启用App Sandbox，Apple Silicon及完整游玩待实测；美术仍几何原型，无音效；仍不能标记项目总目标完成。
- 关联测试用例编号：TC-017
- 关联素材清单编号：无

- 模块名称：阶段9｜像素美术接入（角色与经验球）
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：检索并下载两份CC0素材包（经本地代理，ZIP CRC校验通过，暂存目录隔离）；tools/build_art.py生成全部派生帧：spriggan德鲁伊玩家、狼召唤物、树精Boss（场景2倍显示、碰撞半径16）各idle/walk，史莱姆敌人idle4帧/walk跳跃4帧（降饱和），绿水晶经验球明暗脉冲；五场景接入AnimatedSprite2D并隐藏DebugBody几何占位；玩家/敌人出生即播放idle，召唤物按位移切换walk/idle与翻转；经验球autoplay脉冲；授权登记assets/ART_CREDITS.md与素材清单ART-001～005；主菜单流程截图复核新画面。
- 新增/修改文件（脚本、场景、资源）：assets/art/**（22帧PNG）、assets/ART_CREDITS.md、tools/build_art.py、scenes/player/player.tscn、scenes/enemies/enemy.tscn、scenes/summons/summon.tscn、scenes/bosses/forest_boss.tscn、scenes/pickups/experience_orb.tscn、scripts/player/player.gd、scripts/enemies/enemy.gd、scripts/summons/summon.gd、tests/art_assets_test.gd、tests/run_tests.py、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、主菜单
- 已知限制、待优化点、未解决问题：场地障碍/背景仍几何占位；静态素材的walk为1px浮动派生帧，非手绘逐帧；无音频；新PNG需先--import再跑测试（已生成.import）；导出包尚未包含新素材重建。
- 关联测试用例编号：TC-018
- 关联素材清单编号：ART-001～ART-005

### TC-018
用例ID：TC-018
测试目标：验证像素素材加载、动画播放与调试占位隐藏
前置条件：assets/art已导入（.import存在）；如新增PNG需先执行 --import
测试步骤：运行 tests/art_assets_test.gd；图形模式运行 tests/main_menu_test.gd -- --capture-ui 查看ui-arena.png。
预期结果：五场景AnimatedSprite2D均含32×32帧、Nearest过滤、idle/walk动画齐备；Boss精灵2倍、碰撞半径16；经验球autoplay；DebugBody隐藏；idle出生即播放。
失败判定标准：贴图加载失败、尺寸错误、动画缺失、占位色块可见。
测试环境：Godot4.7.2 Intel headless（资源断言）与OpenGL图形模式（截图）；macOS .app待重建后验收。
调试手段：tests/results/current-art_assets_test.log、tests/results/ui-arena.png。
常见报错排查方向：新PNG未导入导致No loader found；测试实体需分散摆放并禁用攻击，避免互相击杀或拾取干扰断言。
执行记录：24项断言通过；10组全量回归通过；ui-arena.png确认德鲁伊、狼、史莱姆显示正常。

- 模块名称：阶段10｜音效与BGM接入
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：下载两份CC0音频包（代理+ZIP校验，暂存目录隔离）；tools/build_audio.py按映射复制8个音效与1首BGM；新增Sfx（8路AudioStreamPlayer池、音高抖动、played信号、未知名仅警告）与Music（OGG循环、-8dB）两个Autoload；接线召唤物攻击、敌人死亡、经验拾取、升级选择、玩家受伤、胜负结算与UI/主菜单点击；headless下跳过真实播放以规避假音频驱动退出泄漏（信号仍发，真实运行不受影响）；真实图形模式短跑无错误。
- 新增/修改文件（脚本、场景、资源）：assets/audio/sfx/*.wav×8、assets/audio/music/dark_woods.ogg、tools/build_audio.py、scripts/autoload/sfx.gd、scripts/autoload/music.gd、scripts/{player/player.gd,enemies/enemy.gd,summons/summon.gd,progression/experience_orb.gd,ui/run_ui.gd,ui/main_menu.gd}、project.godot、tests/audio_test.gd、tests/run_tests.py、assets/ART_CREDITS.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、主菜单、阶段9
- 已知限制、待优化点、未解决问题：BGM为约36秒短循环，长时间游玩会重复；无音量/静音设置与音频总线；Boss预警与Boss登场暂无专属音效；headless回归不验证真实可听输出，需人工试听。
- 关联测试用例编号：TC-019
- 关联素材清单编号：AUD-001、AUD-002

### TC-019
用例ID：TC-019
测试目标：验证音频Autoload、池化播放与玩法接线
前置条件：assets/audio已导入；Sfx与Music已注册Autoload
测试步骤：运行 tests/audio_test.gd；真实图形模式 --quit-after 300 启动确认无音频错误并人工试听。
预期结果：8个音效全部可加载；play发played信号、未知名仅警告不崩溃；BGM为OGG且loop开启、长度>20秒；召唤攻击/敌人死亡/拾取/受伤各触发一次对应音效。
失败判定标准：流加载失败、播放崩溃、接线静默、退出时出现ERROR。
测试环境：Godot4.7.2 Intel headless（断言经played信号，不断言可听输出）；真实播放需人工在图形模式验收。
调试手段：tests/results/current-audio_test.log、--verbose查看Leaked instance。
常见报错排查方向：headless假音频驱动泄漏播放实例导致退出ERROR（已在headless跳过真实播放）；新音频需先--import。
执行记录：12项断言通过；11组全量回归通过；真实图形模式300帧无错误日志。

- 模块名称：阶段11｜场地美术（地面与障碍）
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：build_art.py新增地形合成：五款DCSS地面瓦片按固定种子拼成640×360深绿森林地面并加深边框（修正了初版grass_full土黄过亮问题，按瓦片实测均值重新选色）；mangrove双树冠拼成48×80障碍图；两个场地基础场景以Sprite2D替换几何占位（碰撞形状不变），主菜单背景改用同一地面图加暗化遮罩；全量回归与图形截图复核通过。
- 新增/修改文件（脚本、场景、资源）：assets/art/arena/floor.png、assets/art/arena/obstacle_tree.png、tools/build_art.py、scenes/test/player_movement_test.tscn、scenes/test/enemy_chase_test.tscn、scripts/ui/main_menu.gd、tests/art_assets_test.gd、assets/ART_CREDITS.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段9、阶段10
- 已知限制、待优化点、未解决问题：地面为静态整图，无昼夜/区域变化；边界外无树林装饰；场地仍只有一个障碍布局。
- 关联测试用例编号：TC-018（扩展4项断言，共28项）
- 关联素材清单编号：ART-006、ART-007

- 模块名称：阶段12｜强化词条扩展
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：升级三选一由固定两项改为从7种词条的可用池中随机抽取3个不同项（不足3个则按实际数量显示）：灵力+5（召唤物伤害）、移速+10%（上限300）、召唤+1（上限5只且继承伤害/攻速/范围加成）、攻击间隔-10%（下限0.1倍）、生命上限+20并恢复20、攻击范围+20%（上限3倍）、拾取范围+40%（上限5倍，动态缩放场上及后续经验球碰撞半径）；Health新增heal与increase_max_health；RunUI.show_choices改为动态标签数组并隐藏多余按钮；arena新增forced_choices测试钩子（为空保持随机）；ui-upgrade.png截图复核随机词条显示正常。
- 新增/修改文件（脚本、场景、资源）：scripts/game/arena.gd、scripts/combat/health.gd、scripts/ui/run_ui.gd、tests/upgrades_test.gd、tests/progression_test.gd、tests/run_tests.py、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～8、阶段9～11
- 已知限制、待优化点、未解决问题：各词条数值未经真实游玩平衡调校；无词条权重/稀有度与禁用重复连胜机制；拾取范围仅作用于经验球碰撞半径，拾取吸附动效未做。
- 关联测试用例编号：TC-011（改用forced_choices适配随机池）、TC-020

### TC-020
用例ID：TC-020
测试目标：验证扩展词条池随机三选一、七种词条效果与可用性上限
前置条件：工程已导入；arena.gd词条池重构完成
测试步骤：运行 tests/upgrades_test.gd（全量回归 python3 tests/run_tests.py 包含）。
预期结果：升级暂停并弹出3个互不相同、带数字编号的选项；UI选择后恢复世界；power/swift/bond/haste/vitality/reach/magnet各自生效（相对断言，兼容UI随机先选）；新召唤物继承伤害；磁吸同时影响场上与新生成经验球；达上限后词条离开池子，仅剩2项时第3按钮隐藏且越界选择被拒绝。
失败判定标准：选项重复、效果数值错误、上限后仍可选中、越界选择生效。
测试环境：Godot4.7.2 Intel headless。
调试手段：tests/results/current-upgrades_test.log；arena.forced_choices可钉住选项。
常见报错排查方向：UI随机先选会污染绝对数值断言，一律用相对断言；bond新召唤物须用差集定位，组顺序不可靠。
执行记录：25项断言通过；12组全量回归通过；图形截图ui-upgrade.png确认随机词条与编号显示正常。

- 模块名称：阶段13｜高负载与长局压力测试
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：新增 tests/stress_test.gd：敌人上限提至120并铺满、5召唤物+4次灵力强化下跑300物理帧，验证召唤物持续击杀、经验球掉落、种群不超上限、平均帧耗16.34ms（<33ms阈值）、对局不中断；随后手动驱动WaveDirector快进完整1800秒长局，验证Boss按时登场、击杀后胜利结算与成绩存档；玩家血量临时放大避免站桩被围杀干扰负载断言。
- 新增/修改文件（脚本、场景、资源）：tests/stress_test.gd、tests/run_tests.py、Woodcaller_Project_Log.md
- 依赖前置模块：阶段1～12
- 已知限制、待优化点、未解决问题：headless帧耗含引擎节流，仅作粗粒度回归门槛；真实30分钟连续游玩、真实键盘输入与切窗焦点、图形模式高负载帧率仍需人工实机验收；敌人围杀下的寻路拥堵未测。
- 关联测试用例编号：TC-021

### TC-021
用例ID：TC-021
测试目标：验证高负载（120敌人群+5召唤物）下的稳定性与完整长局流程
前置条件：工程已导入；阶段12词条系统可用
测试步骤：运行 tests/stress_test.gd（全量回归 python3 tests/run_tests.py 包含）。
预期结果：敌人铺满上限120；300帧内召唤物有击杀、经验球掉落、种群不越上限、平均帧耗<33ms、对局存活；WaveDirector快进到1800秒后Boss登场且仅一次；击杀Boss后暂停并显示胜利结算、存档wins≥1。
失败判定标准：负载下崩溃/报错/无击杀、种群越界、帧耗超标、Boss不登场或长局无法结算。
测试环境：Godot4.7.2 Intel headless。
调试手段：tests/results/current-stress_test.log（含INFO平均帧耗）。
常见报错排查方向：玩家站桩会被围杀导致对局提前结束，须先放大血量；spawn_enemy含110px安全距离与地形查询，铺满循环需设spawned上限防死循环。
执行记录：11项断言通过；13组全量回归通过；平均帧耗16.34ms（116敌人在场）。

- 模块名称：阶段14｜macOS测试包重建（含美术/音频/词条）
- 完成时间：2026-10-25（Asia/Shanghai）
- 实现内容：运行 tools/build_macos.command 重建 macOS Universal 包，纳入阶段9～13全部新素材与代码；签名校验（--verify --deep --strict）通过，二进制x86_64+arm64；压缩包解至/private/tmp独立目录冒烟运行120帧，退出码0、无引擎错误；PCK内逐一确认地面/障碍贴图、BGM与8个音效均已打入。
- 新增/修改文件（脚本、场景、资源）：builds/Woodcaller.app、builds/Woodcaller-macos-universal.zip、EXPORT_MACOS.md、Woodcaller_Project_Log.md
- 依赖前置模块：阶段9～13
- 已知限制、待优化点、未解决问题：仍为ad-hoc本地签名，未公证未开沙盒；Intel冒烟通过不等于Apple Silicon实机通过；手动验收清单（EXPORT_MACOS.md）全部待人工执行。
- 关联测试用例编号：无（构建与冒烟脚本见EXPORT_MACOS.md与tests/results/macos-package-smoke.log）
