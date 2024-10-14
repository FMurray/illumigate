// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const ray = @import("raylib");
const Designer = @import("core/designer.zig").Designer;
const storage = @import("core/storage.zig");

pub fn main() !void {
    const width = 800;
    const height = 600;

    ray.initWindow(width, height, "IllumiGate LED Designer");
    defer ray.closeWindow();

    ray.setTargetFPS(60);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    // // Load geometry
    // const geometry = try storage.loadGeometry(allocator, "new_geometry.json");
    // defer {
    //     for (geometry.sections) |section| {
    //         allocator.free(section.name);
    //         allocator.free(section.type);
    //         allocator.free(section.points);
    //     }
    //     allocator.free(geometry.points);
    //     allocator.free(geometry.sections);
    // }

    // Use the loaded geometry...

    // Save geometry (example with dummy data)
    // const points = [_]storage.Point{
    //     .{ .id = 1, .x = 0, .y = 0, .z = 0 },
    //     .{ .id = 2, .x = 1, .y = 0, .z = 0 },
    //     .{ .id = 3, .x = 0.5, .y = 0.866, .z = 0 },
    // };

    // const sections = [_]storage.Section{
    //     .{
    //         .name = "Triangle1",
    //         .type = "triangle",
    //         .points = &[_]u32{ 1, 2, 3 },
    //     },
    // };

    // const new_geometry = storage.GeometryDefinition{
    //     .points = &points,
    //     .sections = &sections,
    // };

    // try storage.saveGeometry(new_geometry, "new_geometry.json");

    var designer = try Designer.init(allocator, width, height);
    defer designer.deinit();

    while (!ray.windowShouldClose()) {
        designer.update();
        designer.draw();
    }
}
