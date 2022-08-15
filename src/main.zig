pub const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("api/pictapi.h");
});

test "create task" {
    const std = @import("std");
    const print = std.debug.print;

    const PAIRWISE: c_uint = 2;

    try struct {
        fn checkNull(ret: anytype) error{OutOfMemory}!void {
            if (ret == null) {
                return error.OutOfMemory;
            }
        }

        const PictError = error{
            OutOfMemory,
            InternalEngine,
        };

        fn checkRetCode(x: c.PICT_RET_CODE) PictError!void {
            switch (x) {
                c.PICT_SUCCESS => {},
                c.PICT_OUT_OF_MEMORY => {
                    print("Error: {}\n", .{PictError.OutOfMemory});
                    return PictError.OutOfMemory;
                },
                c.PICT_GENERATION_ERROR => {
                    print("Error: {}\n", .{PictError.InternalEngine});
                    return PictError.InternalEngine;
                },
                else => unreachable,
            }
        }

        pub fn main() anyerror!void {
            var ret: c.PICT_RET_CODE = c.PICT_SUCCESS;
            var task: c.PICT_HANDLE = c.PictCreateTask();
            try checkNull(task);
            defer c.PictDeleteTask(task);
            var model: c.PICT_HANDLE = c.PictCreateModel(c.PICT_DEFAULT_RANDOM_SEED);
            try checkNull(model);
            defer c.PictDeleteModel(model);
            c.PictSetRootModel(task, model);

            var weights = [_]c_uint{ 1, 2, 1, 1 };
            var p1: c.PICT_HANDLE = c.PictAddParameter(model, 4, PAIRWISE, &weights);
            try checkNull(p1);
            var p2: c.PICT_HANDLE = c.PictAddParameter(model, 3, PAIRWISE, null);
            try checkNull(p2);
            var p3: c.PICT_HANDLE = c.PictAddParameter(model, 5, PAIRWISE, null);
            try checkNull(p3);
            var p4: c.PICT_HANDLE = c.PictAddParameter(model, 2, PAIRWISE, null);
            try checkNull(p4);
            var p5: c.PICT_HANDLE = c.PictAddParameter(model, 4, PAIRWISE, null);
            try checkNull(p5);

            const EXCLUSION_1_SIZE: usize = 2;

            var excl1 = [EXCLUSION_1_SIZE]c.PICT_EXCLUSION_ITEM{ .{ .Parameter = p1, .ValueIndex = 0 }, .{ .Parameter = p2, .ValueIndex = 0 } };

            ret = c.PictAddExclusion(task, &excl1, EXCLUSION_1_SIZE);
            try checkRetCode(ret);

            const EXCLUSION_2_SIZE: usize = 2;

            var excl2 = [EXCLUSION_2_SIZE]c.PICT_EXCLUSION_ITEM{ .{ .Parameter = p4, .ValueIndex = 1 }, .{ .Parameter = p5, .ValueIndex = 2 } };

            ret = c.PictAddExclusion(task, &excl2, EXCLUSION_2_SIZE);
            try checkRetCode(ret);

            const SEED_1_SIZE: usize = 5;

            var seed1 = [SEED_1_SIZE]c.PICT_SEED_ITEM{ .{ .Parameter = p1, .ValueIndex = 1 }, .{ .Parameter = p2, .ValueIndex = 1 }, .{ .Parameter = p3, .ValueIndex = 1 }, .{ .Parameter = p4, .ValueIndex = 1 }, .{ .Parameter = p5, .ValueIndex = 1 } };

            ret = c.PictAddSeed(task, &seed1, SEED_1_SIZE);
            try checkRetCode(ret);

            ret = c.PictGenerate(task);
            try checkRetCode(ret);

            var row: c.PICT_RESULT_ROW = c.PictAllocateResultBuffer(task);
            try checkNull(row);
            defer c.PictFreeResultBuffer(row);

            var paramCount: usize = c.PictGetTotalParameterCount(task);

            c.PictResetResultFetching(task);

            while (c.PictGetNextResultRow(task, row) != 0) {
                var index: usize = 0;
                while (index < paramCount) : (index += 1) {
                    print("{} ", .{row[index]});
                }
                print("\n", .{});
            }
        }
    }.main();
}
