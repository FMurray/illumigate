// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const ray = @import("raylib");
const Designer = @import("core/designer.zig").Designer;

pub fn main() !void {
    const width = 800;
    const height = 600;

    ray.initWindow(width, height, "IllumiGate LED Designer");
    defer ray.closeWindow();

    ray.setTargetFPS(60);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var designer = try Designer.init(allocator, width, height);
    defer designer.deinit();

    while (!ray.windowShouldClose()) {
        designer.update();
        designer.draw();
    }
}
