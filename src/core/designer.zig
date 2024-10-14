const std = @import("std");
const ray = @import("raylib");
const raygui = @import("raygui");
const geometry = @import("geometry.zig");

pub const Designer = struct {
    window_width: i32,
    window_height: i32,
    camera: ray.Camera3D,
    led_strips: std.ArrayList(geometry.LedStrip),
    line_params: geometry.LineParams,
    triangle_params: geometry.TriangleParams,

    pub fn init(allocator: std.mem.Allocator, width: i32, height: i32) !Designer {
        return Designer{
            .window_width = width,
            .window_height = height,
            .camera = ray.Camera3D{
                .position = ray.Vector3{ .x = 10.0, .y = 10.0, .z = 10.0 },
                .target = ray.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 },
                .up = ray.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 },
                .fovy = 45.0,
                .projection = ray.CameraProjection.camera_perspective,
            },
            .led_strips = try std.ArrayList(geometry.LedStrip).initCapacity(allocator, 10),
            .line_params = .{ .length = 5.0, .density = 20.0 },
            .triangle_params = .{ .width = 5.0, .height = 5.0, .density = 60.0 },
        };
    }

    pub fn deinit(self: *Designer) void {
        self.led_strips.deinit();
    }

    pub fn update(self: *Designer) void {
        ray.updateCamera(&self.camera, ray.CameraMode.camera_free);
    }

    pub fn draw(self: *Designer) void {
        ray.beginDrawing();
        defer ray.endDrawing();

        ray.clearBackground(ray.Color.white);

        ray.beginMode3D(self.camera);
        self.drawLedStrips();
        ray.drawGrid(10, 1.0);
        ray.endMode3D();

        self.drawGui();
    }

    fn drawLedStrips(self: *Designer) void {
        for (self.led_strips.items) |strip| {
            strip.draw();
        }
    }

    fn drawGui(self: *Designer) void {
        ray.drawText("IllumiGate LED Designer", 10, 10, 20, ray.Color.black);
        ray.drawFPS(10, 40);

        if (raygui.guiButton(ray.Rectangle{ .x = 10, .y = 70, .width = 200, .height = 30 }, "Add LED Strip") == 1) {
            self.addLedStrip();
        }

        if (raygui.guiButton(ray.Rectangle{ .x = 10, .y = 110, .width = 200, .height = 30 }, "Add Triangle") == 1) {
            self.addTriangle();
        }

        const start_y: f32 = 150.0; // Starting Y position for the sliders
        const spacing: f32 = 40.0; // Vertical spacing between sliders
        const slider_width: f32 = 200.0; // Width of the slider
        const slider_height: f32 = 20.0; // Height of the slider

        // Line parameters
        _ = raygui.guiSliderBar(ray.Rectangle{ .x = 10, .y = start_y + spacing * 0, .width = slider_width, .height = slider_height }, "Line Length", "", &self.line_params.length, 1.0, 10.0);
        _ = raygui.guiSliderBar(ray.Rectangle{ .x = 10, .y = start_y + spacing * 1, .width = slider_width, .height = slider_height }, "Line Density", "", &self.line_params.density, 10.0, 100.0);

        // Triangle parameters
        _ = raygui.guiSliderBar(ray.Rectangle{ .x = 10, .y = start_y + spacing * 2, .width = slider_width, .height = slider_height }, "Triangle Width", "", &self.triangle_params.width, 1.0, 10.0);
        _ = raygui.guiSliderBar(ray.Rectangle{ .x = 10, .y = start_y + spacing * 3, .width = slider_width, .height = slider_height }, "Triangle Height", "", &self.triangle_params.height, 1.0, 10.0);
        _ = raygui.guiSliderBar(ray.Rectangle{ .x = 10, .y = start_y + spacing * 4, .width = slider_width, .height = slider_height }, "Triangle Density", "", &self.triangle_params.density, 10.0, 100.0);
    }

    fn addLedStrip(self: *Designer) void {
        const new_strip = geometry.LedStrip.init(ray.Vector3{ .x = 0, .y = 0, .z = 0 }, ray.Vector3{ .x = self.line_params.length, .y = 0, .z = 0 }, self.line_params);
        self.led_strips.append(new_strip) catch |err| {
            std.debug.print("Failed to add LED strip: {}\n", .{err});
        };
    }

    fn addTriangle(self: *Designer) void {
        const new_triangle = geometry.LedStrip.initTriangle(ray.Vector3{ .x = 0, .y = 0, .z = 0 }, ray.Vector3{ .x = self.triangle_params.width, .y = 0, .z = 0 }, ray.Vector3{ .x = self.triangle_params.width / 2, .y = self.triangle_params.height, .z = 0 }, self.triangle_params);
        self.led_strips.append(new_triangle) catch |err| {
            std.debug.print("Failed to add LED triangle: {}\n", .{err});
        };
    }
};
