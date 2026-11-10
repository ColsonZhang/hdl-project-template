# Vivado 工程骨架（Tcl 重建，不入库生成物）

本目录提供**最小可改的 Vivado Tcl 流程骨架**。Vivado 工程与输出全部由脚本生成，Git 只保存脚本/约束/源码。

> ⚠️ 模板按 Vivado 2022.2 习惯编写，**未在真实工程实测**（本机无 Vivado）；首次使用时按报错微调。Vivado 版本/器件以你本机安装为准。

## 目录

```
tool/Vivado/
├── launch_vivado.sh        # 非交互：source settings + 跑 create_project.tcl
├── launch_gui.sh           # 打开 Vivado GUI
├── clean.sh                # 删除 projects/ output/ 与 log/jou
├── xdc/                    # 约束文件（模板：timing.xdc，时钟约束占位）
└── scripts/
    ├── common/function.tcl # 通用函数：递归收集源码、加源、设顶层、读约束
    └── project/
        ├── config.tcl      # ★ 唯一参数事实源：工程名/器件/顶层/xdc/目录
        ├── create_project.tcl  # 建工程 + 加 src/lib 源码 + 设顶层 + 读 xdc
        ├── sync_sources.tcl    # 已有工程：把 src/lib 新增文件同步进工程
        └── save_outputs.tcl    # 跑实现并导出 bit（BD 工程可加 hwh/ltx）
```

## 使用步骤

1. **改配置**：编辑 `scripts/project/config.tcl` 的 `project_name`、`part_name`、`top_module`、`xdc_file`。
2. **改约束**：编辑 `xdc/timing.xdc`（至少给主时钟，端口名与顶层一致）。
3. 安装/定位 Vivado：`export VIVADO_SETTINGS=/tools/Xilinx/Vivado/2022.2/settings64.sh`（默认值即此）。
4. 建工程：

```bash
cd tool/Vivado
bash launch_vivado.sh        # 生成 projects/<project_name>/<project_name>.xpr
```

5. 之后迭代：改完 RTL 重新 `bash launch_vivado.sh`（或 `-source sync_sources.tcl` 同步），
   或在 Vivado Tcl 控制台：

```tcl
cd tool/Vivado/scripts/project
source create_project.tcl     ;# 首次
source sync_sources.tcl       ;# 之后同步源码
source save_outputs.tcl       ;# 综合/实现/导出 bit（会检查 impl_1 进度）
```

## 说明

- **不要提交** `projects/`、`output/` 与 `*.log/*.jou/*.Xpr` 等生成物（见 `.gitignore`）。
- 新增源码不需要改任何工程脚本：`create_project.tcl`/`sync_sources.tcl` 会递归扫 `src/` 与 `lib/`
  （自动跳过 `testbench/` 与 `abandon/` 目录）。
- 需要 IP/BD 时：在 `scripts/designs/` 下新增 Tcl（例如 `ips/` 生成 BRAM IP、`bd/` 拼 Block Design），
  在 `create_project.tcl` 末尾 `source` 它们，或由 `write_bd_tcl` 导出后保存到 `scripts/designs/bd/`。
  生成的 BD wrapper/网表 `.v` 可按项目决定是否入库（模板 `.gitignore` 未忽略 `scripts/`）。
- 若使用 board file 而不是 part，把 `create_project` 的 `-part` 换成 `-board` 并设 `board_part`。
