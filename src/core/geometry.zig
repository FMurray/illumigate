const std = @import("std");
const ray = @import("raylib");
const storage = @import("storage.zig");

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

pub fn createLedStripsFromGeometry(allocator: std.mem.Allocator, geometry: storage.GeometryDefinition, params: TriangleParams) !std.ArrayList(LedStrip) {
    std.debug.print("Creating LedStrips from geometry\n", .{});
    var led_strips = std.ArrayList(LedStrip).init(allocator);
    errdefer led_strips.deinit();

    std.debug.print("Number of sections: {d}\n", .{geometry.sections.len});
    for (geometry.sections, 0..) |section, i| {
        std.debug.print("Processing section {d}\n", .{i});

        if (section.type.len == 0) {
            std.debug.print("Section type is empty\n", .{});
            continue;
        }

        std.debug.print("Section type: {s}\n", .{section.type});
        std.debug.print("Number of points in section: {d}\n", .{section.points.len});

        if (std.mem.eql(u8, section.type, "triangle")) {
            std.debug.print("Section {d} is a triangle\n", .{i});
            if (section.points.len != 3) {
                std.debug.print("Invalid number of points for triangle: {d}\n", .{section.points.len});
                return error.InvalidTrianglePoints;
            }

            std.debug.print("Accessing points\n", .{});
            for (section.points) |point_index| {
                if (point_index == 0 or point_index > geometry.points.len) {
                    std.debug.print("Invalid point index: {d}\n", .{point_index});
                    return error.InvalidPointIndex;
                }
            }

            // adjust to 0-based from 1-based index
            const p1 = geometry.points[section.points[0] - 1];
            const p2 = geometry.points[section.points[1] - 1];
            const p3 = geometry.points[section.points[2] - 1];

            std.debug.print("Triangle points: ({d},{d},{d}), ({d},{d},{d}), ({d},{d},{d})\n", .{ p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p3.x, p3.y, p3.z });

            std.debug.print("Creating new triangle\n", .{});
            const new_triangle = LedStrip.initTriangle(ray.Vector3{ .x = p1.x, .y = p1.y, .z = p1.z }, ray.Vector3{ .x = p2.x, .y = p2.y, .z = p2.z }, ray.Vector3{ .x = p3.x, .y = p3.y, .z = p3.z }, params);
            std.debug.print("Appending triangle to led_strips\n", .{});
            try led_strips.append(new_triangle);
            std.debug.print("Triangle added to led_strips\n", .{});
        } else {
            std.debug.print("Unknown section type\n", .{});
        }
    }

    std.debug.print("LedStrips creation completed\n", .{});
    return led_strips;
}
