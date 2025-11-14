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

    const lib = b.addLibrary(.{
        .name = "storm",
        .win32_manifest = b.path("src/DllMain.def"),
        .root_module = mod_storm,
    });

    //================
    // Setting Dynamic/Static
    // Invoke with `-Ddynamic=[true|false]`
    //================
    const dynamic = b.option(
        bool,
        "dynamic",
        "Builds as dynamic library on true, static on false",
    ) orelse false;
    if (dynamic) {
        lib.linkage = .dynamic;
    } else {
        lib.linkage = .static;
    }
    //================

    b.installArtifact(lib);

    try targets.append(b.allocator, lib);
    _ = zcc.createStep(b, "cdb", try targets.toOwnedSlice(b.allocator));
}
