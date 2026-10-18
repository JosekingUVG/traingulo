const std = @import("std");
const rl = @import("raylib");
const Triangle = @import("triangles.zig").Triangle;
const Framebuffer = @import("framebuffer.zig").Framebuffer;
const cute_colors = @import("cute_colors.zig");

pub fn main(_: std.process.Init) !void {
    rl.initWindow(800, 600, "Triangle Example");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var framebuffer = Framebuffer.init(800, 600, cute_colors.htmlColor("#000000"), null);
    defer framebuffer.deinit();

    const triangle = Triangle{
        .a = .{
            .position = .{ .x = 400, .y = 100, .z = 0 },
            .color = cute_colors.htmlColor("#ff0000"),
        },
        .b = .{
            .position = .{ .x = 150, .y = 450, .z = 0 },
            .color = cute_colors.htmlColor("#00ff00"),
        },
        .c = .{
            .position = .{ .x = 650, .y = 450, .z = 0 },
            .color = cute_colors.htmlColor("#0000ff"),
        },
    };

    try draw(&framebuffer, triangle);

    while (!rl.windowShouldClose()) {
        try framebuffer.swap_buffers(false);
    }
}

fn draw(framebuffer: *Framebuffer, triangle: Triangle) !void {
    for (100..451) |y| {
        for (150..651) |x| {
            const point = rl.Vector3{
                .x = @as(f32, @floatFromInt(x)) + 0.5,
                .y = @as(f32, @floatFromInt(y)) + 0.5,
                .z = 0,
            };

            if (triangle.calculateUVW(point)) |weights| {
                framebuffer.set_current_color(triangle.paintColor(weights));
                try framebuffer.set_pixel(
                    @intCast(x),
                    @intCast(y),
                );
            }
        }
    }
}
