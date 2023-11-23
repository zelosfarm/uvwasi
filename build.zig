const std = @import("std");
const builtin = @import("builtin");

const ArrayList = std.ArrayList;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uvwasi = b.addStaticLibrary(.{
        .name = "uvwasi",
        .target = target,
        .optimize = optimize,
    });
    uvwasi.linkLibC();
    uvwasi.linkLibrary(b.dependency("uv", .{
        .target = target,
        .optimize = optimize,
    }).artifact("uv"));
    uvwasi.addIncludePath(.{ .path = "include" });
    uvwasi.addIncludePath(.{ .path = "src" });

    var uvwasi_flags = ArrayList([]const u8).init(b.allocator);
    var uvwasi_sources = ArrayList([]const u8).init(b.allocator);
    defer uvwasi_flags.deinit();
    defer uvwasi_sources.deinit();

    uvwasi_sources.append("src/clocks.c") catch @panic("OOM");
    uvwasi_sources.append("src/fd_table.c") catch @panic("OOM");
    uvwasi_sources.append("src/path_resolver.c") catch @panic("OOM");
    uvwasi_sources.append("src/poll_oneoff.c") catch @panic("OOM");
    uvwasi_sources.append("src/sync_helpers.c") catch @panic("OOM");
    uvwasi_sources.append("src/uv_mapping.c") catch @panic("OOM");
    uvwasi_sources.append("src/uvwasi.c") catch @panic("OOM");
    uvwasi_sources.append("src/wasi_rights.c") catch @panic("OOM");
    uvwasi_sources.append("src/wasi_serdes.c") catch @panic("OOM");

    uvwasi.addCSourceFiles(.{ .files = uvwasi_sources.items, .flags = uvwasi_flags.items });

    uvwasi.installHeadersDirectory("include", "");

    b.installArtifact(uvwasi);
}
