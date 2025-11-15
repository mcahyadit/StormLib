const std = @import("std");
const zcc = @import("compile_commands");

pub fn build(b: *std.Build) !void {
    var targets = std.ArrayList(*std.Build.Step.Compile){};

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod_storm = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    mod_storm.addCSourceFiles(.{
        .files = &.{
            "src/adpcm/adpcm.cpp",
            "src/huffman/huff.cpp",
            "src/jenkins/lookup3.c",
            "src/lzma/C/LzFind.c",
            "src/lzma/C/LzmaDec.c",
            "src/lzma/C/LzmaEnc.c",
            "src/pklib/explode.c",
            "src/pklib/implode.c",
            "src/sparse/sparse.cpp",
            "src/FileStream.cpp",
            "src/SBaseCommon.cpp",
            "src/SBaseDumpData.cpp",
            "src/SBaseFileTable.cpp",
            "src/SBaseSubTypes.cpp",
            "src/SCompression.cpp",
            "src/SFileAddFile.cpp",
            "src/SFileAttributes.cpp",
            "src/SFileCompactArchive.cpp",
            "src/SFileCreateArchive.cpp",
            "src/SFileExtractFile.cpp",
            "src/SFileFindFile.cpp",
            "src/SFileGetFileInfo.cpp",
            "src/SFileListFile.cpp",
            "src/SFileOpenArchive.cpp",
            "src/SFileOpenFileEx.cpp",
            "src/SFilePatchArchives.cpp",
            "src/SFileReadFile.cpp",
            "src/SFileVerify.cpp",
            "src/SMemUtf8.cpp",
            "src/libtomcrypt/src/pk/rsa/rsa_verify_simple.c",
            "src/libtomcrypt/src/misc/crypt_libc.c",
        },
        .flags = &.{
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-D_7ZIP_ST",
            "-DBZ_STRICT_ANSI",
            "-fPIC", // Zig Compile to Dynamic
        },
    });

    mod_storm.linkSystemLibrary("zlib", .{});
    mod_storm.linkSystemLibrary("bzip2", .{});
    mod_storm.linkSystemLibrary("tomcrypt", .{});
    mod_storm.linkSystemLibrary("tommath", .{});

    var linkage: std.builtin.LinkMode = .static;
    //================
    // Setting Dynamic/Static
    // Invoke with `-Ddynamic=[true|false]`
    //================
    const dynamic = b.option(
        bool,
        "dynamic",
        "Builds as dynamic library on true, static on false",
    ) orelse false;
    std.debug.print("dynamic = {}\n", .{dynamic});
    if (dynamic) {
        linkage = .dynamic;
    }
    //================

    const lib = b.addLibrary(.{
        .name = "storm",
        .linkage = linkage,
        .win32_manifest = b.path("src/DllMain.def"),
        .root_module = mod_storm,
    });

    b.installArtifact(lib);

    //================
    // Test
    //================
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/test_wrap.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    test_module.addCSourceFiles(.{
        .files = &.{
            "test/StormTest.cpp",
        },
    });
    test_module.addImport("storm", mod_storm);
    test_module.linkSystemLibrary("alsa", .{});
    const test_artifact = b.addTest(.{
        .root_module = test_module,
    });
    const test_run = b.addRunArtifact(test_artifact);
    const test_step = b.step("test", "Run Tests");
    test_step.dependOn(&test_run.step);
    //================

    try targets.append(b.allocator, lib);
    _ = zcc.createStep(b, "cdb", try targets.toOwnedSlice(b.allocator));
}
