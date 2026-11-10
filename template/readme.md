# <项目名> HDL 工程

> 这是由 `hdl-project-template` skill 提供的**空白 HDL 项目模板**。把整个目录复制到新位置，再按需改名/加代码即可。

## 目录组织

```
<project>/
├── readme.md              # 本文件：项目说明 + 快速开始
├── .gitignore             # 忽略 **abandon/ 、**testbench_data/
├── src/                   # 设计源码：按功能域分目录，模块旁挂 testbench/
│   └── common/            # 通用设施：default_pkg.sv、template_tb.sv
├── lib/                   # 第三方 / 厂商 / IP 仿真模型
├── test/                  # 仿真数据根：test/testbench_data/<dataset>/（不入库）
└── tool/
    ├── VCS/               # 仿真入口 Makefile（自动生成 filelist）
    ├── VeribleFilelist/   # Python filelist 生成器（模块依赖 DFS）
    └── Vivado/            # Vivado Tcl 工程骨架 + xdc 模板
```

## 快速开始

### 0. 环境

- **VCS / Verdi / Vivado 需在 Linux 上运行**；Windows 侧适合编辑源码与脚本。
- filelist 生成器依赖：`python3` + `pip install anytree` + verible 二进制
  （首次在 `tool/VeribleFilelist/` 下执行 `bash initial.sh` 下载 Linux 版）。
- Vivado 版本按本机安装调整（模板按 2022.2 习惯编写，未实测）。

### 1. 改成你的项目

1. 改本文件标题与说明。
2. 改 `tool/Vivado/scripts/project/config.tcl`：`project_name`、`board_part`、`top_module`、xdc 文件名。
3. 改 `tool/Vivado/xdc/timing.xdc` 的时钟端口名/周期。
4. （可选）`git init` 并把 `tool/Vivado/projects/`、`output/` 等生成物保持在忽略列表内。

### 2. 加第一个功能域和模块

```bash
mkdir -p src/<domain>/<block>/testbench
# 写 src/<domain>/<block>/<block>_top.sv（文件名 = module 名），需要时再拆子模块
# 写 src/<domain>/<block>/testbench/<block>_top_tb.sv（从 src/common/testbench/template_tb.sv 复制）
```

- `src/common/` 只放跨域共享的 package/原语/接口与 tb 模板。
- 模块间用命名端口例化；参数用全大写；时钟复位建议 `clk` + 高有效 `rst`。
- 需要"版本升级"时复制成 `X_v2.sv` 并只在上层替换例化，旧版保留（可选习惯）。

### 3. 跑 VCS 仿真（Linux）

```bash
cd tool/VCS
make topmodule=<tb模块名> compile   # 自动生成 filelist/<top>.f 并编译，产物 out/simv
make topmodule=<tb模块名> run       # 跑仿真，日志 log/run.log，波形 out/<tb>.vcd
make topmodule=<tb模块名> compile_gui && make run_gui   # 调试版（Verdi/DVE）
make clean                          # 清编译产物
```

`topmodule` 写 **模块名**（不是文件名/路径）；默认是模板自带的 `template_tb`，可先跑它验证环境。

### 4. 建 Vivado 工程（Linux）

见 `tool/Vivado/README.md`：先改配置，再 `bash tool/Vivado/launch_vivado.sh`，或按 README 在 Vivado Tcl 控制台分步执行。

## 约定速览

| 约定 | 说明 |
|---|---|
| 一个文件一个 module | 文件名 = module 名；可综合源码用 `.sv` |
| 功能域目录 | `src/<domain>/...`，每层模块旁挂 `testbench/` |
| testbench 命名 | `<DutName>_tb.sv`；模块从 `src/common/testbench/template_tb.sv` 复制 |
| 公共仿真设施 | `src/common/default_pkg.sv`（`sys_clock_set/sys_reset/sys_delay/...`） |
| 时间尺度 | 不要写 `` `timescale``；由 `tool/VCS/Makefile` 的 `-timescale=1ps/1ps` 统一 |
| 仿真数据 | `test/testbench_data/<dataset>/`（gitignore）；tb 用 `` `ROOT_DIR `` 拼路径 |
| 废弃代码 | 挪进任意 `abandon/`（git 忽略 + filelist 自动剪枝） |
| 生成物 | Vivado 工程/输出、filelist、波形、日志一律不入库 |

更多细节见 skill 的 `SKILL.md` 与 `template/tool/*/README`。
