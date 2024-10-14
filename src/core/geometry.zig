const std = @import("std");
const ray = @import("raylib");

pub const Shape = union(enum) {
    Line: struct { start: ray.Vector3, end: ray.Vector3 },
    Triangle: struct { a: ray.Vector3, b: ray.Vector3, c: ray.Vector3 },
};

pub const LedStripParams = struct {
    density: f32, // LEDs per meter
};

pub const LineParams = struct {
    length: f32,
    density: f32,
};

pub const TriangleParams = struct {
    width: f32,
    height: f32,
    density: f32,
};

pub const LedStrip = struct {
    shape: Shape,
    num_leds: usize,
    params: LedStripParams,

    pub fn init(start: ray.Vector3, end: ray.Vector3, params: LineParams) LedStrip {
        const length = ray.Vector3.distance(start, end);
        const num_leds = @as(usize, @intFromFloat(length * params.density));
        return LedStrip{
            .shape = .{ .Line = .{ .start = start, .end = end } },
            .num_leds = num_leds,
            .params = .{ .density = params.density },
        };
    }

    pub fn initTriangle(a: ray.Vector3, b: ray.Vector3, c: ray.Vector3, params: TriangleParams) LedStrip {
        const perimeter = ray.Vector3.distance(a, b) + ray.Vector3.distance(b, c) + ray.Vector3.distance(c, a);
        const num_leds = @as(usize, @intFromFloat(perimeter * params.density));
        return LedStrip{
            .shape = .{ .Triangle = .{ .a = a, .b = b, .c = c } },
            .num_leds = num_leds,
            .params = .{ .density = params.density },
        };
    }

    pub fn draw(self: LedStrip) void {
        switch (self.shape) {
            .Line => |line| self.drawLine(line.start, line.end),
            .Triangle => |triangle| self.drawTriangle(triangle.a, triangle.b, triangle.c),
        }
    }

    fn drawLine(self: LedStrip, start: ray.Vector3, end: ray.Vector3) void {
        ray.drawLine3D(start, end, ray.Color.red);
        self.drawLEDsAlongEdge(start, end);
    }

    fn drawTriangle(self: LedStrip, a: ray.Vector3, b: ray.Vector3, c: ray.Vector3) void {
        ray.drawLine3D(a, b, ray.Color.red);
        ray.drawLine3D(b, c, ray.Color.red);
        ray.drawLine3D(c, a, ray.Color.red);

        self.drawLEDsAlongEdge(a, b);
        self.drawLEDsAlongEdge(b, c);
        self.drawLEDsAlongEdge(c, a);
    }

    fn drawLEDsAlongEdge(self: LedStrip, start: ray.Vector3, end: ray.Vector3) void {
        const edge_length = ray.Vector3.distance(start, end);
        const num_leds_on_edge = @as(usize, @intFromFloat(edge_length * self.params.density));

        const step_x = (end.x - start.x) / @as(f32, @floatFromInt(num_leds_on_edge));
        const step_y = (end.y - start.y) / @as(f32, @floatFromInt(num_leds_on_edge));
        const step_z = (end.z - start.z) / @as(f32, @floatFromInt(num_leds_on_edge));

        var i: usize = 0;
        while (i < num_leds_on_edge) : (i += 1) {
            const led_pos = ray.Vector3{
                .x = start.x + step_x * @as(f32, @floatFromInt(i)),
                .y = start.y + step_y * @as(f32, @floatFromInt(i)),
                .z = start.z + step_z * @as(f32, @floatFromInt(i)),
            };
            ray.drawSphere(led_pos, 0.1, ray.Color.red);
        }
    }
};
