const std = @import("std");

pub fn streql(a: anytype, b: anytype) bool {
    const slice_a = castStrToSlice(a);
    const slice_b = castStrToSlice(b);
    return std.mem.eql(u8, slice_a, slice_b);
}

pub fn castStrToSlice(a: anytype) []const u8 {
    const T = @TypeOf(a);
    switch (@typeInfo(T)) {
        .pointer => |p| {
            switch (@typeInfo(p.child)) {
                .array => |t| {
                    if (t.child != u8) @compileError(expected_u8_child ++ @typeName(t.child));

                    // pointer to an array of u8
                    return std.mem.span(@as([*:0]const u8, @ptrCast(a)));
                },
                .int => |t| {
                    if (p.child != u8) @compileError(expected_u8_child ++ @typeName(t.child));

                    // pointer with sentinel to u8 array
                    return std.mem.span(a);
                },
                else => @compileError(expected_u8_child ++ @typeName(T)),
            }
        },
        else => @compileError(invalid_ptr_type ++ @typeName(T)),
    }
}

const expected_u8_child = "Expected u8 children got ";
const invalid_ptr_type = "Invalid pointer type: ";
