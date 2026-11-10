# src/ 设计源码组织

- **按功能域划分目录**：`src/<domain>/...`。domain 是子系统/算法族等逻辑划分，按项目自行命名；不要把所有模块平铺在 `src/` 根下。
- **一个文件一个 module**，文件名 = module 名；可综合源码写 `.sv`（厂商/历史 `.v` 放 `lib/`）。
- **每个模块目录旁挂 `testbench/` 子目录**：`src/<domain>/<block>/testbench/<DutName>_tb.sv`。filelist 生成器靠目录名恰为 `testbench` 来归类 tb。
- **共享设施放 `src/common/`**：
  - `default_pkg.sv`：仿真用 `sys_clock/sys_reset/sys_delay/printf...` 任务（testbench 必须 `import default_pkg::*;`，可综合 RTL 不要 import）。
  - `testbench/template_tb.sv`：testbench 骨架模板（Makefile 默认顶层就是它）。
  - 跨域通用原语（mux/fifo/边沿检测等）也可放这里。
- **命名建议**：
  - 功能域/模块用 PascalCase（如 `PixelPipe_top.sv`），纯通用原语可用 snake_case；
  - 角色后缀表达职责：`_top`（组装顶层）、`_unit`（最小重复单元）、`_datapath`（纯连线数据通路）、`_ctrl`（控制 FSM）、`_wrapper`（参数/端口汇总）、`_tb`（testbench）；
  - 参数全大写、带组前缀（如 `DW_*`/`NUM_*`），端口与信号小写 `snake_case`。
- **版本升级（可选习惯）**：复制 `X.sv` → `X_v2.sv`，只在上层替换例化，旧版本保留；当前有效版本看"谁在例化"。
- 例化统一命名端口 `.port(sig)`；时钟复位建议 `clk` + 高有效 `rst`（低有效用 `rst_n`）。
- 文件头可统一为 `@Author / @Date / @Description` 注释（团队约定即可，模板未强制）。
