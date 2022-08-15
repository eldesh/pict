pub const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("api/pictapi.h");
});

test "create task" {
    var task: c.PICT_HANDLE = c.PictCreateTask();
    _ = task;
}
