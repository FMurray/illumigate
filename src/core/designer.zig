const std = @import("std");
const ray = @import("raylib");
const raygui = @import("raygui");

pub const Designer = struct {
    window_width: i32,
    window_height: i32,
    camera: ray.Camera3D,
    led_strips: std.ArrayList(LedStrip),

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
            .led_strips = try std.ArrayList(LedStrip).initCapacity(allocator, 10),
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
    }

    fn addLedStrip(self: *Designer) void {
        const new_strip = LedStrip.init(ray.Vector3{ .x = 0, .y = 0, .z = 0 }, ray.Vector3{ .x = 5, .y = 0, .z = 0 }, 20);
        self.led_strips.append(new_strip) catch |err| {
            std.debug.print("Failed to add LED strip: {}\n", .{err});
        };
    }
};

const LedStrip = struct {
    start: ray.Vector3,
    end: ray.Vector3,
    num_leds: usize,

    pub fn init(start: ray.Vector3, end: ray.Vector3, num_leds: usize) LedStrip {
        return LedStrip{
            .start = start,
            .end = end,
            .num_leds = num_leds,
        };
    }

    pub fn draw(self: LedStrip) void {
        ray.drawLine3D(self.start, self.end, ray.Color.red);

        const step_x = (self.end.x - self.start.x) / @as(f32, @floatFromInt(self.num_leds));
        const step_y = (self.end.y - self.start.y) / @as(f32, @floatFromInt(self.num_leds));
        const step_z = (self.end.z - self.start.z) / @as(f32, @floatFromInt(self.num_leds));

        var i: usize = 0;
        while (i < self.num_leds) : (i += 1) {
            const led_pos = ray.Vector3{
                .x = self.start.x + step_x * @as(f32, @floatFromInt(i)),
                .y = self.start.y + step_y * @as(f32, @floatFromInt(i)),
                .z = self.start.z + step_z * @as(f32, @floatFromInt(i)),
            };
            ray.drawSphere(led_pos, 0.1, ray.Color.red);
        }
    }
};
