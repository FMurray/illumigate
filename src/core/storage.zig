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
    name: []u8,
    type: []u8,
    points: []u32,
};

pub const GeometryDefinition = struct {
    points: []Point,
    sections: []Section,
};

pub fn loadGeometry(allocator: std.mem.Allocator, file_path: []const u8) !GeometryDefinition {
    // Read the entire file content
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    // Parse the JSON content
    var parsed = try std.json.parseFromSlice(GeometryDefinition, allocator, content, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
    defer parsed.deinit();

    // Create a new GeometryDefinition with owned memory
    var result = GeometryDefinition{
        .points = try allocator.dupe(Point, parsed.value.points),
        .sections = try allocator.alloc(Section, parsed.value.sections.len),
    };

    // Copy sections with owned memory
    for (parsed.value.sections, 0..) |section, i| {
        result.sections[i] = Section{
            .name = try allocator.dupe(u8, section.name),
            .type = try allocator.dupe(u8, section.type),
            .points = try allocator.dupe(u32, section.points),
        };
    }

    return result;
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
