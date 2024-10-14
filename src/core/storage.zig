const std = @import("std");
const json = std.json;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub const Point = struct {
    id: u32,
    x: f32,
    y: f32,
    z: f32,
};

pub const Section = struct {
    name: []const u8,
    type: []const u8,
    points: []const u32,
};

pub const GeometryDefinition = struct {
    points: []const Point,
    sections: []const Section,
};

pub fn loadGeometry(allocator: std.mem.Allocator, file_path: []const u8) !GeometryDefinition {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var parser = try json.parseFromSlice(GeometryDefinition, allocator, buffer, .{});
    defer parser.deinit();

    const root = parser.value;

    var points = ArrayList(Point).init(allocator);
    defer points.deinit();

    for (root.points) |json_point| {
        const point = Point{
            .id = json_point.id,
            .x = json_point.x,
            .y = json_point.y,
            .z = json_point.z,
        };
        try points.append(point);
    }

    var sections = ArrayList(Section).init(allocator);
    defer sections.deinit();

    for (root.sections) |json_section| {
        const section = Section{
            .name = try allocator.dupe(u8, json_section.name),
            .type = try allocator.dupe(u8, json_section.type),
            .points = try allocator.dupe(u32, json_section.points),
        };
        try sections.append(section);
    }

    return GeometryDefinition{
        .points = try points.toOwnedSlice(),
        .sections = try sections.toOwnedSlice(),
    };
}

pub fn saveGeometry(geometry: GeometryDefinition, file_path: []const u8) !void {
    // Open a file for writing
    var file = try std.fs.cwd().createFile(file_path, .{});
    defer file.close();

    // Create a file writer
    const writer = file.writer();

    // Use std.json.stringify to write JSON directly to the file
    try std.json.stringify(geometry, .{}, writer);
}
