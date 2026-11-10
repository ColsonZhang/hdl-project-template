# HDL Project Template

一个可复用的**空白 HDL（Verilog / SystemVerilog）项目模板**，同时也是一个 **agent skill**（DeepSeek Harness / Claude Code 风格的 `SKILL.md` + resources）。
它把 HDL 工程的目录组织、VCS 仿真流程、Verible 自动 filelist、Vivado Tcl 工程骨架、公共仿真 package 与 testbench 模板打包成"复制即用"的脚手架。

> A reusable blank HDL project template that doubles as an agent skill: project layout, VCS flow with automatic filelist generation, Vivado Tcl scaffold, simulation package and testbench skeletons.

## 特性

- **目录四分**：`src/` 可综合设计、`lib/` 厂商/IP 仿真模型、`tool/` 构建脚本、`test/` 仿真数据；生成物（工程/波形/filelist/日志/数据）一律不入库。
- **组织约定**：`src/<domain>/...` 按功能域分目录；一个文件一个 module，文件名 = module 名；每个模块目录旁挂 `testbench/`。
- **VCS 一键仿真**：`make topmodule=<tb> compile` / `make run`；filelist 由 `tool/VeribleFilelist` 从 top 模块按依赖 DFS **自动生成**，不需要手写。
- **公共仿真设施**：`src/common/default_pkg.sv`（`sys_clock/sys_reset/sys_delay/printf/get_testbench_name`）+ 8 段式 `template_tb.sv`（Makefile 默认顶层，可开箱验证环境）。
- **Vivado 工程骨架**：Tcl 重建工程（`config.tcl` / `create_project.tcl` / `sync_sources.tcl` / `save_outputs.tcl`）+ xdc 约束模板 + 启动/清理脚本。
- **约定内置**：`abandon/` 废弃代码区、`testbench_data/` 数据区（均 gitignore）、`` `ROOT_DIR `` 数据路径、`USE_VCS_SIMULATION` 仿真分支、统一 `-timescale=1ps/1ps`（不写 `timescale`）。

## 作为 skill 使用

### DeepSeek Harness

把本仓库放到 DSH 的技能目录（任选其一）：

```bash
# 全局（所有工作区可用）
git clone https://github.com/ColsonZhang/hdl-project-template.git ~/.dsh/skills/hdl-project-template

# 或项目级（只有该项目可用）
git clone https://github.com/ColsonZhang/hdl-project-template.git <project>/.dsh/skills/hdl-project-template
```

之后在会话里用 `skill` 工具加载 `hdl-project-template`（技能名 = 仓库名）。

### Claude Code / 其他 agent

把仓库放进对应的 skills 目录（如 `~/.claude/skills/hdl-project-template/`），`SKILL.md` 会被识别。

## 创建新 HDL 项目

```bash
bash scripts/new_hdl_project.sh ~/work/my_hdl_project
```

或手动复制：

```bash
cp -a template/. ~/work/my_hdl_project/
cd ~/work/my_hdl_project && git init
```

然后替换占位：

| 文件 | 改什么 |
|---|---|
| `readme.md` | 项目名与说明 |
| `tool/Vivado/scripts/project/config.tcl` | `project_name`、`part_name`（FPGA 器件）、`top_module`、`xdc_file` |
| `tool/Vivado/xdc/timing.xdc` | 主时钟端口名与周期 |

## 仓库结构

```
hdl-project-template/
├── SKILL.md                      # skill 入口：创建流程、目录约定、构建流程、检查清单
├── README.md                     # 本文件
├── LICENSE
├── NOTICE
├── scripts/
│   └── new_hdl_project.sh        # 一键复制模板到新项目
└── template/                     # ★ 空白项目模板（复制到新项目根目录）
    ├── readme.md
    ├── .gitignore                # **abandon/  **testbench_data/
    ├── src/
    │   ├── readme.md             # 目录/命名约定
    │   └── common/
    │       ├── default_pkg.sv    # 仿真任务 package
    │       └── testbench/template_tb.sv
    ├── lib/readme.md             # 第三方/厂商/IP 仿真模型
    ├── test/readme.md            # 数据根（testbench_data 不入库）
    └── tool/
        ├── VCS/{Makefile,.gitignore}
        ├── VeribleFilelist/      # Python filelist 生成器
        └── Vivado/               # Tcl 工程骨架 + xdc
```

## 环境要求

- **VCS / Verdi / Vivado 只在 Linux 上运行**；Windows 侧适合编辑源码与脚本。
- filelist 生成器：`python3`、`pip install anytree`、verible 二进制（首次在 `tool/VeribleFilelist/` 执行 `bash initial.sh`）。
- Vivado 版本按本机安装调整（模板按 2022.2 习惯编写）。

## 已知限制

- `tool/Vivado` 下的 Tcl 是**通用骨架，未在真实工程实测**；首次使用请按本机 Vivado 版本/器件微调。
- VCS 流程需要旧式 `vcs`/`verdi` 环境与 `-full64` 工具链；模板未在 Windows 验证。
- `template/` 不含任何具体项目的模块命名（`src/` 只有 `common/`），按需自建功能域目录。

## 第三方代码

`template/tool/VeribleFilelist/verible_verilog_syntax.py` 来自 The Verible Authors 的 `verible-verilog-syntax` Python wrapper，使用 Apache License 2.0，文件内保留原始版权头。详见 [NOTICE](NOTICE)。

## License

[Apache License 2.0](LICENSE)
