const std = @import("std");

extern fn test_entry(argc: c_int, argv: *const [*:0] u8) callconv(.c) c_int;

test "StormLib_Test" {
    const result = test_entry(0, "stormlib-test-001.txt");
    try std.testing.expectEqual(0, result);
}
