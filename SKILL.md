---
name: hdl-project-template
description: 用空白模板创建新的 HDL/RTL 项目：一键复制 src/lib/tool/test 目录骨架（VCS + VeribleFilelist 自动 filelist、Vivado Tcl 工程、公共仿真 package 与 testbench 模板），并按"一个文件一个 module、模块旁挂 testbench/"的约定组织代码。用户要新建 Verilog/SystemVerilog 项目、搭 RTL 工程脚手架、初始化仿真/综合流程，或问"新 HDL 项目目录/构建流程怎么搭"时使用。
whenToUse: 用户要新建 HDL 项目、复制工程模板、搭建 RTL 目录或仿真/综合脚手架、初始化 VCS/Vivado 构建流程时。
---

# HDL 项目模板

本 skill 自带一个**空白 HDL 项目模板**（`template/`）：目录骨架 + VCS 仿真流程 + VeribleFilelist 自动 filelist + Vivado Tcl 工程骨架 + 公共仿真 package/testbench 模板。复制后只填内容，不改流程。

- 模板内容：`template/`（复制到新项目根目录）
- 一键脚本：`scripts/new_hdl_project.sh <目标目录>`
- 本 skill 不含任何具体项目的模块/目录命名；`src/` 是空的（只有 `common/` 公共设施）。

## 1. 创建新项目

```bash
bash <skill目录>/scripts/new_hdl_project.sh ~/work/my_hdl_project
```

等价手动操作：

```bash
cp -a <skill目录>/template/. <目标目录>/
cd <目标目录> && git init        # 可选
```

然后按顺序替换占位：

| 文件 | 改什么 |
|---|---|
| `readme.md` | 项目名与说明 |
| `tool/Vivado/scripts/project/config.tcl` | `project_name`、`part_name`（FPGA 器件）、`top_module`、`xdc_file` |
| `tool/Vivado/xdc/timing.xdc` | 主时钟端口名与周期（解除注释） |
| `.gitignore` | 按项目补充需要忽略的生成物（默认已忽略 `**abandon/`、`**testbench_data/`） |

## 2. 模板目录结构

```
<project>/
├── readme.md                  # 项目说明 + 快速开始
├── .gitignore                 # **abandon/  **testbench_data/
├── src/
│   ├── readme.md              # src 组织约定
│   └── common/                # 跨域共享设施
│       ├── default_pkg.sv     # 仿真时钟/复位/延时/打印 task（tb 统一 import）
│       └── testbench/
│           └── template_tb.sv # testbench 8 段骨架模板（Makefile 默认顶层）
├── lib/
│   └── readme.md              # 第三方/厂商/IP 仿真模型（按来源分目录）
├── test/
│   └── readme.md              # 数据根：test/testbench_data/<dataset>/（不入库）
└── tool/
    ├── VCS/
    │   ├── Makefile           # 仿真入口：filelist→compile→run（12 个 target）
    │   └── .gitignore         # 忽略 filelist/out/log/csrc/波形
    ├── VeribleFilelist/       # Python filelist 生成器（模块依赖 DFS）
    │   ├── main.py database.py parse.py preprocess.py verible_verilog_syntax.py
    │   ├── initial.sh         # 下载 Linux 版 verible
    │   └── readme.md
    └── Vivado/
        ├── README.md          # 流程说明与使用步骤
        ├── launch_vivado.sh   # source settings + create_project.tcl
        ├── launch_gui.sh      # 打开 Vivado GUI
        ├── clean.sh           # 删 projects/ output/ 与日志
        ├── scripts/common/function.tcl   # 递归收源码/加源/设顶层/读 xdc
        ├── scripts/project/{config,create_project,sync_sources,save_outputs}.tcl
        └── xdc/timing.xdc     # 时钟/IO/False path 约束模板
```

## 3. 组织约定（模板已内置）

- **顶层四分**：`src/` 可综合设计、`lib/` 厂商/IP 仿真模型、`tool/` 构建脚本、`test/` 仿真数据；生成物（工程/波形/filelist/日志/数据）一律不入库。
- **`src/` 按功能域分目录**：`src/<domain>/...`，domain 是子系统/算法族等逻辑划分；不要全部平铺在 `src/` 根下。
- **一个文件一个 module，文件名 = module 名**；可综合源码用 `.sv`。
- **模块旁挂 `testbench/`**：`src/<domain>/<block>/testbench/<DutName>_tb.sv`。filelist 生成器按目录名恰为 `testbench` 归类。
- **共享设施放 `src/common/`**：`default_pkg.sv`（仿真 task）、`template_tb.sv`（tb 骨架）、跨域原语；tb 必须 `import default_pkg::*;`，可综合 RTL 不要 import。
- **不要写 `` `timescale``**：时间尺度由 `tool/VCS/Makefile` 的 `-timescale=1ps/1ps` 统一提供；`sys_delay(n)` 的 n 是周期数。
- **仿真数据**放 `test/testbench_data/<dataset>/`（被 gitignore），tb 用 Makefile 注入的 `` `ROOT_DIR `` 拼绝对路径。
- **废弃代码**挪进任意 `abandon/` 目录：git 忽略，filelist 生成器也整棵剪枝。
- 可选习惯（推荐）：接口/行为大改时复制 `X_v2.sv` 升级、上层替换例化、旧版保留；角色后缀表达职责（`_top/_unit/_datapath/_ctrl/_wrapper/_tb`）。

## 4. 添加代码

```bash
# 新功能域 + 第一个模块
mkdir -p src/<domain>/<block>/testbench
# 1) 写 src/<domain>/<block>/<block>_top.sv  （文件名=module 名）
# 2) 复制 tb 骨架并改 module 名
cp src/common/testbench/template_tb.sv src/<domain>/<block>/testbench/<block>_top_tb.sv
#    文件内 `define TB_MODULE_NAME 改成 <block>_top_tb
# 3) 跑仿真（Linux）
cd tool/VCS && make topmodule=<block>_top_tb compile && make topmodule=<block>_top_tb run
```

testbench 8 段骨架（模板已带，勿删减）：① `import default_pkg::*` + `` `define TB_MODULE_NAME `` ② 参数（watchdog/波形/数据路径） ③ `assign clk/rst = sys_*` ④ DUT 命名端口例化 ⑤ `fork{main_procedure, watchdog, sys_clock_run, sys_count_run}` ⑥ `$dumpfile("out/<tb>.vcd")` ⑦ `main_procedure`（`sys_reset`→激励→`sys_info_sim_end`→`$finish`） ⑧ watchdog task。

VB/SystemVerilog 小约定：参数全大写带组前缀；端口/信号小写 `snake_case`；例化全部命名端口 `.port(sig)`；时钟 `clk` + 高有效 `rst`（低有效用 `rst_n`）。

## 5. 构建流程

### VCS 仿真（Linux）

前置：VCS + Verdi；`python3`、`pip install anytree`；首次在 `tool/VeribleFilelist/` 跑 `bash initial.sh` 下载 verible（Linux 静态包）。

```bash
cd tool/VCS
make topmodule=<tb模块名> compile    # 自动生成 filelist/<top>.f → vcs → out/simv
make topmodule=<tb模块名> run        # ./out/simv -l log/run.log；波形 out/<tb>.vcd
make topmodule=<tb模块名> compile_gui && make run_gui   # 调试版（Verdi/DVE）
make clean                           # 清 csrc/out/log
```

- `topmodule` 写**模块名**（不是文件名/路径）；默认 `template_tb`，可先跑它验证环境。
- `compile → lint → make_filelist` 自动生成 filelist；**绝不手写/提交 filelist**。
- filelist 生成逻辑：扫描 `-s`（默认 `../../src ../../lib`）→ 目录名 `testbench` 归 tb、`abandon` 剪枝、`.svh` 只贡献 `+incdir+` → 从 top 模块按"实例化 + import"依赖做后序 DFS → 只包含可达文件，依赖在前、tb 最后。
- 改 `` `ifdef ``/define 后必须重建缓存：`rm -rf tool/VeribleFilelist/cache`（或 `-b`），因为缓存不记录 defines。
- 编译产物 `out/simv` 单文件覆盖；`run` 不检查 simv 是否最新，先 compile 再 run。
- Windows 只能编辑源码/脚本，VCS/verible/Vivado 都是 Linux 工具。

### Vivado 工程（Linux，模板需按本机微调）

```bash
export VIVADO_SETTINGS=/tools/Xilinx/Vivado/<版本>/settings64.sh   # 或直接改脚本默认值
cd tool/Vivado
bash launch_vivado.sh        # create_project.tcl：建工程 + 加 src/lib 源码 + 设顶层 + 读 xdc
```

之后迭代：`source scripts/project/sync_sources.tcl` 同步新增 RTL；`source scripts/project/save_outputs.tcl` 跑实现并导出 bit 到 `output/<project>/`。详见 `template/tool/Vivado/README.md`。

> ⚠️ Vivado 脚本是**通用骨架、未在真实工程实测**（本机无 Vivado）；首次使用按报错微调器件/版本/约束。新增 IP/BD 时在 `tool/Vivado/scripts/designs/` 下加 Tcl 并在 `create_project.tcl` 末尾 source。

## 6. 常见坑（模板相关）

1. `topmodule` 写错（文件名/路径/大小写）时 filelist 仍会生成并打印 `!!! Filelist generated failed`，VCS 报找不到模块——写模块名。
2. tb 不在 `src/` 或 `lib/` 搜索路径内（例如放 `test/`）→ 永远不会进 filelist。
3. 改 define/`ifdef` 后复用旧缓存 → 依赖图过期；删 `tool/VeribleFilelist/cache`。
4. 缺 verible 二进制时 `import database` 直接 AssertionError；`initial.sh` 只给 Linux。
5. 一个文件多个 module / 模块重名 → filelist 生成器只告警或静默覆盖；坚持一文件一 module、全仓唯一命名。
6. 数据路径硬编码 → 换机即挂；用 `` `ROOT_DIR `` + `test/testbench_data/<dataset>/`。
7. 提交了生成物（`projects/`、`output/`、`filelist/`、`out/`、`log/`）→ 检查各 `.gitignore`；模板已忽略。
8. Vivado 脚本依赖本机安装路径/器件；版本不符时先改 `VIVADO_SETTINGS` 与 `config.tcl`。

## 7. 新项目检查清单

- [ ] 用 `new_hdl_project.sh`（或 `cp -a template/.`）生成项目，确认 `git status` 只有预期文件。
- [ ] 改 `readme.md` / `config.tcl` / `timing.xdc` 占位。
- [ ] Linux 上跑通模板 tb：`make topmodule=template_tb compile && make topmodule=template_tb run`，确认 `filelist/template_tb.f`、`out/simv`、`out/template_tb.vcd` 生成。
- [ ] 新增第一个功能域 + 模块 + tb，`make topmodule=<tb> compile run` 通过。
- [ ] 确认 `git status` 未出现 `filelist/`、`out/`、`log/`、`csrc/`、`projects/`、`output/`、`testbench_data/`。
- [ ] Vivado：按 README 建工程、设顶层/约束，`save_outputs.tcl` 能出 bit（按本机版本微调后）。
