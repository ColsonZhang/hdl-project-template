# lib/ 第三方 / 厂商 / IP 仿真模型

- 放 vendor 提供的仿真模型、Xilinx unisim/IP 仿真模型、手工改写的 RAM/FIFO 行为模型等，建议按来源分目录：`lib/<vendor>/...`。
- `tool/VCS/Makefile` 的 `SEARCH_PATH` 默认包含 `../../lib`（递归扫描），所以 `lib/` 下的 `.sv/.v` 会自动成为 filelist 候选；不需要手工维护列表。
- **生成物不入库**：例如 Vivado 生成的 IP 仿真模型目录（`lib/<...>/gen/`）请写进 `.gitignore`。
- 若某些厂商原语在纯 VCS 环境不可用，可用 `` `ifdef USE_VCS_SIMULATION `` 在 RTL 里切换到行为模型（该宏由 Makefile 注入）。
- 第三方代码请保留原始版权头，并在本目录 README 或注释里记录来源与版本。
