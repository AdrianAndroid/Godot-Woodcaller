# 素材授权登记（ART CREDITS）

本文件登记 assets/art/ 下全部第三方素材的来源、授权与本地修改。
两个来源均为 CC0（公有领域），允许商用、修改且无需署名；此处仍保留署名以示感谢。

## 1. Dungeon Crawl Stone Soup 32×32 图块集

- 来源页面：https://opengameart.org/content/dungeon-crawl-32x32-tiles
- 下载文件：Dungeon Crawl Stone Soup Full_0.zip（含 LICENSE.txt，CC0）
- 授权：CC0 1.0（https://creativecommons.org/publicdomain/zero/1.0/）
- 维护者：Chris Hamons；Dungeon Crawl Stone Soup 项目众多贡献者
- 用途与本地修改（tools/build_art.py 自动生成）：
  - monster/spriggan/spriggan_druid.png → assets/art/player/druid_*（玩家；派生 1px 浮动 idle/walk 帧）
  - monster/animals/wolf.png → assets/art/summons/wolf_*（召唤物；同上派生帧）
  - monster/fungi_plants/treant.png → assets/art/bosses/treant_*（Boss；同上派生帧，场景内 2 倍显示）
  - item/misc/misc_crystal_new.png → assets/art/pickups/exp_orb_*（经验球；色相旋转为绿色并派生明暗脉冲帧）
  - dungeon/floor/{moss_0, bog_green_0_new, grass/grass_0_new, dirt_0_new, grass/grass_flowers_blue_1_new}.png → assets/art/arena/floor.png（640×360 固定种子拼贴，压暗并加深四周边框，兼作主菜单背景）
  - dungeon/trees/mangrove_1.png → assets/art/arena/obstacle_tree.png（48×80 双树冠拼贴，压暗）

## 2. Pixel Art Animated Slime

- 来源页面：https://opengameart.org/content/pixel-art-animated-slime
- 下载文件：Slime_0.zip（页面标注 License: CC0）
- 授权：CC0 1.0
- 作者：rvros
- 用途与本地修改：slime-Sheet.png 4×4 切片 → assets/art/enemies/slime_*；
  降低饱和度与明度以匹配低饱和暗黑森林基调；idle 取帧 0-2 循环，walk 取跳跃帧 4/6/8/10。

## 3. The Essential Retro Video Game Sound Effects Collection（512 音效）

- 来源页面：https://opengameart.org/content/512-sound-effects-8-bit-style
- 下载文件：The Essential Retro Video Game Sound Effects Collection [512 sounds].zip（内含 INFO.txt 声明 CC0）
- 授权：CC0 1.0
- 作者：Juhani Junkala
- 用途（tools/build_audio.py 原样复制重命名，未修改内容）：
  - Weapons/Melee/sfx_wpn_punch1.wav → assets/audio/sfx/attack.wav（召唤物攻击）
  - Death Screams/Alien/sfx_deathscream_alien1.wav → assets/audio/sfx/enemy_die.wav（敌人死亡）
  - General Sounds/Coins/sfx_coin_cluster1.wav → assets/audio/sfx/pickup.wav（拾取经验）
  - General Sounds/Positive Sounds/sfx_sounds_powerup2.wav → assets/audio/sfx/levelup.wav（升级选择）
  - General Sounds/Negative Sounds/sfx_sounds_damage1.wav → assets/audio/sfx/hurt.wav（玩家受伤）
  - General Sounds/Fanfares/sfx_sounds_fanfare1.wav → assets/audio/sfx/win.wav（胜利）
  - General Sounds/Negative Sounds/sfx_sounds_negative1.wav → assets/audio/sfx/lose.wav（失败）
  - General Sounds/Menu Sounds/sfx_menu_select1.wav → assets/audio/sfx/ui_click.wav（UI 点击）

## 4. Dark Woods Loop（BGM）

- 来源页面：https://opengameart.org/content/dark-woods-loop
- 下载文件：dark_woods_in_game.ogg
- 授权：CC0 1.0
- 作者：beardalea
- 用途：assets/audio/music/dark_woods.ogg，主菜单与对局内循环播放（约 36 秒循环，-8 dB，Music autoload）。

## 导入设置

- 全部美术素材为 32×32 透明 PNG（RGBA）。
- 各场景 AnimatedSprite2D 节点设置 texture_filter = Nearest（1），保持硬边像素。
- 派生帧由 tools/build_art.py 生成，可重复执行：`python3 -I tools/build_art.py [暂存目录]`。
- 音效为 44100Hz 16bit WAV，音乐为 OGG Vorbis；由 tools/build_audio.py 复制，可重复执行：`python3 -I tools/build_audio.py [暂存目录]`。
