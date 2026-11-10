# test/ 仿真数据根目录

- 测试数据统一放 `test/testbench_data/<dataset>/`（压缩包、激励文件、权重、黄金结果等）。
- `testbench_data/` 被根 `.gitignore` 的 `**testbench_data/` 忽略，**永不入库**；clone 后需自备数据。
- testbench 里用 `ROOT_DIR`（由 `tool/VCS/Makefile` 的 `+define+ROOT_DIR` 编译期注入）拼绝对路径，这样换机器/换 clone 目录都不用改 tb：

```systemverilog
parameter string PATH_PREFIX = $sformatf("%s/test/testbench_data/<dataset>/", `ROOT_DIR);
```

- 常用读取/导出：`$readmemh` / `$readmemb` / `$fscanf` 读，`$writememh` / `$fdisplay` 导出，再在仓库外与黄金结果比对。
- 不要用作者机绝对路径（如 `/home/...`、`/data/...`）硬编码数据路径。
- 本目录可以按需加 `test/scripts/` 等辅助脚本，但不要把大文件入库。
