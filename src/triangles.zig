const rl = @import("raylib");
const std = @import("std");

pub const Barycentric = struct {
    u: f32,
    v: f32,
    w: f32,
};

pub const Vertex = struct {
    position: rl.Vector3,
    color: rl.Color,
};

pub const Triangle = struct {
    a: Vertex,
    b: Vertex,
    c: Vertex,

    // Área doble con signo en el plano XY; conserva la orientación.
    fn doubleArea(a: rl.Vector3, b: rl.Vector3, c: rl.Vector3) f32 {
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    }

    pub fn calculateUVW(self: Triangle, point: rl.Vector3) ?Barycentric {
        const area = doubleArea(self.a.position, self.b.position, self.c.position);
        if (area == 0) return null;

        const u = doubleArea(point, self.b.position, self.c.position) / area;
        const v = doubleArea(self.a.position, point, self.c.position) / area;
        const w = doubleArea(self.a.position, self.b.position, point) / area;
        if (u < 0 or v < 0 or w < 0) return null;

        return .{ .u = u, .v = v, .w = w };
    }

    pub fn paintColor(
        self: Triangle,
        barycentric: Barycentric,
    ) rl.Color {
        return .{
            .r = interpolateChannel(
                self.a.color.r,
                self.b.color.r,
                self.c.color.r,
                barycentric,
            ),
            .g = interpolateChannel(
                self.a.color.g,
                self.b.color.g,
                self.c.color.g,
                barycentric,
            ),
            .b = interpolateChannel(
                self.a.color.b,
                self.b.color.b,
                self.c.color.b,
                barycentric,
            ),
            .a = 255,
        };
    }

    fn interpolateChannel(
        a: u8,
        b: u8,
        c: u8,
        barycentric: Barycentric,
    ) u8 {
        const value =
            @as(f32, @floatFromInt(a)) * barycentric.u +
            @as(f32, @floatFromInt(b)) * barycentric.v +
            @as(f32, @floatFromInt(c)) * barycentric.w;

        return @intFromFloat(@min(255.0, @max(0.0, value)));
    }
};
