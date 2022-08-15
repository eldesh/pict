# PICT - Zig binding

This repo provides libpict-zig binding that requires static library libpict.a.
Which library is built with Makefile:

```
make
zig build test
```

# Link libpict.zig

To link libpict.zig to your Zig project:

```
const linkPict = @import("path/to/libpict.git/build.zig").linkPict;
try linkPict(exe);
exe.addPackagePath("libpict", "path/to/libpict.zig/src/main.zig");
```


