// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// How full the volume holding some path is.
class DiskSpace {
  const DiskSpace({
    required this.totalBytes,
    required this.freeBytes,
    required this.availableBytes,
  });

  /// Capacity of the volume.
  final int totalBytes;

  /// Unused capacity, including the part reserved for the superuser.
  final int freeBytes;

  /// The part of [freeBytes] this user could actually write to. This is the
  /// number a person recognises as "free space"; it is what Finder and
  /// Explorer show.
  final int availableBytes;

  int get usedBytes => totalBytes - freeBytes;

  double get usedFraction =>
      totalBytes == 0 ? 0 : (usedBytes / totalBytes).clamp(0.0, 1.0);

  DiskSpace copyWith({int? freeBytes, int? availableBytes}) => DiskSpace(
    totalBytes: totalBytes,
    freeBytes: freeBytes ?? this.freeBytes,
    availableBytes: availableBytes ?? this.availableBytes,
  );

  @override
  String toString() =>
      'DiskSpace(total: $totalBytes, free: $freeBytes, '
      'available: $availableBytes)';
}

/// Exact disk figures, straight from the operating system.
///
/// Dart's own `FileStat` carries an *apparent* size — the logical length of a
/// file — and no notion of free space at all. Neither is what a user gets back
/// when they delete something: a filesystem allocates in blocks, may compress
/// (APFS does, routinely), and may share blocks between cloned files. The only
/// honest source for "how much space is this really costing" is the same
/// `st_blocks` field `du` reads, and the only source for free space is the
/// same `statfs` call `df` makes.
///
/// This talks to those two calls directly through `dart:ffi` rather than
/// through a plugin. A plugin would mean three native build files, three
/// method channels and an async hop, to reach a C ABI that has not changed in
/// thirty years.
///
/// **Everything here fails soft.** A missing symbol, an unknown platform or a
/// struct offset that does not agree with what Dart already knows leaves the
/// probe reporting `null`, and the caller falls back to the apparent size.
/// Reporting a wrong number confidently would be worse than reporting none.
class NativeDisk {
  NativeDisk({DynamicLibrary? library})
    : _library = library ?? _openPlatformLibrary();

  final DynamicLibrary? _library;

  static NativeDisk? _instance;

  /// The process-wide probe. The bindings are stateless and the self-check
  /// costs a syscall, so there is no reason to build more than one.
  static NativeDisk get shared => _instance ??= NativeDisk();

  static DynamicLibrary? _openPlatformLibrary() {
    try {
      if (Platform.isWindows) return DynamicLibrary.open('kernel32.dll');
      // Both macOS and Linux resolve libc symbols out of the running process.
      return DynamicLibrary.process();
    } on Object {
      return null;
    }
  }

  _StatfsBinding? _statfsCache;
  bool _statfsResolved = false;
  _WindowsSpaceBinding? _windowsSpaceCache;
  bool _windowsSpaceResolved = false;
  _LstatBinding? _lstatCache;
  bool _lstatResolved = false;

  bool get supportsVolumeSpace =>
      Platform.isWindows ? _windowsSpace != null : _statfs != null;

  bool get supportsAllocatedSize => _lstat != null;

  // -------------------------------------------------------------- free space

  /// Capacity and free space of the volume holding [path], or null when the
  /// path does not exist or the platform has no binding.
  DiskSpace? spaceFor(String path) {
    if (Platform.isWindows) return _windowsSpace?.call(path);
    return _statfs?.call(path);
  }

  // ---------------------------------------------------------- on-disk size

  /// Bytes [path] actually occupies on disk — `st_blocks × 512`, the same
  /// arithmetic `du` does.
  ///
  /// Does not follow symlinks: it is `lstat`, so a link reports the handful of
  /// bytes the link itself costs rather than the size of its target. Safety
  /// rail 3 depends on that, and so does any total that would otherwise
  /// double-count a linked tree.
  ///
  /// Null on Windows, which has no equivalent cheap call, and null for a path
  /// that does not exist.
  int? allocatedSize(String path) => _lstat?.call(path);

  // ---------------------------------------------------------------- bindings

  _StatfsBinding? get _statfs {
    if (_statfsResolved) return _statfsCache;
    _statfsResolved = true;
    return _statfsCache = _resolveStatfs();
  }

  _WindowsSpaceBinding? get _windowsSpace {
    if (_windowsSpaceResolved) return _windowsSpaceCache;
    _windowsSpaceResolved = true;
    return _windowsSpaceCache = _resolveWindowsSpace();
  }

  _LstatBinding? get _lstat {
    if (_lstatResolved) return _lstatCache;
    _lstatResolved = true;
    return _lstatCache = _resolveLstat();
  }

  _StatfsBinding? _resolveStatfs() {
    final library = _library;
    if (library == null) return null;

    if (Platform.isMacOS) {
      // `struct statfs` on macOS, verified with `offsetof` on arm64:
      //   f_bsize   uint32  @0
      //   f_blocks  uint64  @8
      //   f_bfree   uint64  @16
      //   f_bavail  uint64  @24
      // x86_64 exports the 64-bit-inode variant under a decorated name; arm64
      // never had the old one, so the plain name is the whole story there.
      final fn = _lookupPosix(library, const ['statfs', r'statfs$INODE64']);
      if (fn == null) return null;
      return _makeStatfs(fn, size: 2304, bsize: _Field.u32(0), blocks: 8);
    }

    if (Platform.isLinux) {
      // glibc `struct statvfs` on 64-bit:
      //   f_bsize   ulong @0
      //   f_frsize  ulong @8   <- the unit f_blocks is counted in
      //   f_blocks  u64   @16
      //   f_bfree   u64   @24
      //   f_bavail  u64   @32
      final fn = _lookupPosix(library, const ['statvfs64', 'statvfs']);
      if (fn == null) return null;
      return _makeStatfs(fn, size: 128, bsize: _Field.u64(8), blocks: 16);
    }

    return null;
  }

  /// Builds a reader for a `statfs`/`statvfs`-shaped struct.
  ///
  /// The two differ only in where the block size lives and how wide it is, so
  /// one reader parameterised by offsets covers both rather than two
  /// near-identical functions.
  _StatfsBinding _makeStatfs(
    _PosixPathCall fn, {
    required int size,
    required _Field bsize,
    required int blocks,
  }) => (String path) {
    final buffer = calloc<Uint8>(size);
    final native = path.toNativeUtf8();
    try {
      if (fn(native.cast(), buffer.cast()) != 0) return null;
      final blockSize = bsize.read(buffer);
      if (blockSize <= 0) return null;
      final total = buffer.cast<Uint64>()[blocks ~/ 8];
      final free = buffer.cast<Uint64>()[blocks ~/ 8 + 1];
      final available = buffer.cast<Uint64>()[blocks ~/ 8 + 2];
      return DiskSpace(
        totalBytes: total * blockSize,
        freeBytes: free * blockSize,
        availableBytes: available * blockSize,
      );
    } on Object {
      return null;
    } finally {
      calloc.free(buffer);
      calloc.free(native);
    }
  };

  _WindowsSpaceBinding? _resolveWindowsSpace() {
    final library = _library;
    if (library == null || !Platform.isWindows) return null;

    final fn = _lookupWindowsSpace(library);
    if (fn == null) return null;

    return (String path) {
      // The call wants a directory; a file path is rejected outright, so a
      // caller passing one gets its parent instead of a null.
      final directory = FileSystemEntity.isDirectorySync(path)
          ? path
          : _parentOf(path);
      final native = directory.toNativeUtf16();
      final available = calloc<Uint64>();
      final total = calloc<Uint64>();
      final free = calloc<Uint64>();
      try {
        if (fn(native.cast(), available, total, free) == 0) return null;
        return DiskSpace(
          totalBytes: total.value,
          freeBytes: free.value,
          availableBytes: available.value,
        );
      } on Object {
        return null;
      } finally {
        calloc
          ..free(native)
          ..free(available)
          ..free(total)
          ..free(free);
      }
    };
  }

  _LstatBinding? _resolveLstat() {
    final library = _library;
    if (library == null) return null;
    if (!Platform.isMacOS && !Platform.isLinux) return null;

    // macOS arm64, verified with `offsetof`: st_size @96, st_blocks @104,
    // struct is 144 bytes. x86_64 matches, under the decorated symbol.
    //
    // Linux is the same two offsets on both x86_64 and aarch64 — the fields
    // before them are shuffled between the two, but st_size lands at 48 and
    // st_blocks at 64 either way.
    final (sizeOffset, blocksOffset, structSize, names) = Platform.isMacOS
        ? (96, 104, 160, const ['lstat', r'lstat$INODE64'])
        : (48, 64, 160, const ['lstat64', 'lstat']);

    final fn = _lookupPosix(library, names);
    if (fn == null) return null;

    int? read(String path, int offset) {
      final buffer = calloc<Uint8>(structSize);
      final native = path.toNativeUtf8();
      try {
        if (fn(native.cast(), buffer.cast()) != 0) return null;
        return buffer.cast<Int64>()[offset ~/ 8];
      } on Object {
        return null;
      } finally {
        calloc.free(buffer);
        calloc.free(native);
      }
    }

    // The self-check. A wrong offset does not crash — it returns a plausible
    // number, which is far more dangerous than a failure. So before trusting
    // the layout at all, stat a file whose length Dart already knows and
    // insist the struct agrees. If it does not, this platform gets no native
    // sizing and the apparent-size fallback stands.
    if (!_layoutAgrees((path) => read(path, sizeOffset))) return null;

    return (String path) {
      final blocks = read(path, blocksOffset);
      return blocks == null ? null : blocks * 512;
    };
  }

  /// True when [readSize] reports the same length for a scratch file that Dart
  /// does, which is only possible if the struct offsets are right.
  static bool _layoutAgrees(int? Function(String) readSize) {
    Directory? scratch;
    try {
      scratch = Directory.systemTemp.createTempSync('kruftle_ffi');
      const length = 4097; // Deliberately not a block multiple.
      final probe = File('${scratch.path}/probe')
        ..writeAsBytesSync(List.filled(length, 0));
      return readSize(probe.path) == length;
    } on Object {
      return false;
    } finally {
      try {
        scratch?.deleteSync(recursive: true);
      } on Object {
        // A probe we cannot tidy up is still a valid probe.
      }
    }
  }

  /// Looks a POSIX `int f(const char*, void*)` up under each name in turn.
  ///
  /// `statfs`, `statvfs` and `lstat` all have that shape, which is why one
  /// helper serves all three. Libc exports them under different names
  /// depending on platform and vintage — `statfs$INODE64` on x86_64 macOS,
  /// `statvfs64` on glibc — and a name that is absent throws rather than
  /// returning null, so each candidate is tried inside its own guard.
  ///
  /// `lookupFunction` needs its native type statically, so this cannot be
  /// generic over the signature; that is the whole reason it is one concrete
  /// helper rather than a type parameter.
  static _PosixPathCall? _lookupPosix(
    DynamicLibrary library,
    List<String> names,
  ) {
    for (final name in names) {
      try {
        return library.lookupFunction<_PosixPathNative, _PosixPathDart>(name);
      } on Object {
        continue;
      }
    }
    return null;
  }

  static _GetDiskFreeSpaceExDart? _lookupWindowsSpace(DynamicLibrary library) {
    try {
      return library
          .lookupFunction<_GetDiskFreeSpaceExNative, _GetDiskFreeSpaceExDart>(
            'GetDiskFreeSpaceExW',
          );
    } on Object {
      return null;
    }
  }

  static String _parentOf(String path) {
    final separator = path.contains(r'\') ? r'\' : '/';
    final cut = path.lastIndexOf(separator);
    return cut <= 0 ? path : path.substring(0, cut);
  }
}

/// One integer inside a struct, described by where it starts and how wide it
/// is. `statfs` and `statvfs` disagree on both for the block size.
class _Field {
  const _Field(this.offset, this.width);

  const _Field.u32(int offset) : this(offset, 4);
  const _Field.u64(int offset) : this(offset, 8);

  final int offset;
  final int width;

  int read(Pointer<Uint8> buffer) => width == 4
      ? buffer.cast<Uint32>()[offset ~/ 4]
      : buffer.cast<Uint64>()[offset ~/ 8];
}

typedef _StatfsBinding = DiskSpace? Function(String path);
typedef _WindowsSpaceBinding = DiskSpace? Function(String path);
typedef _LstatBinding = int? Function(String path);

/// The shape `statfs`, `statvfs` and `lstat` all share: a path in, a struct
/// out, zero for success.
typedef _PosixPathNative = Int32 Function(Pointer<Utf8>, Pointer<Void>);
typedef _PosixPathDart = int Function(Pointer<Utf8>, Pointer<Void>);
typedef _PosixPathCall = _PosixPathDart;

typedef _GetDiskFreeSpaceExNative =
    Int32 Function(
      Pointer<Utf16>,
      Pointer<Uint64>,
      Pointer<Uint64>,
      Pointer<Uint64>,
    );
typedef _GetDiskFreeSpaceExDart =
    int Function(
      Pointer<Utf16>,
      Pointer<Uint64>,
      Pointer<Uint64>,
      Pointer<Uint64>,
    );
