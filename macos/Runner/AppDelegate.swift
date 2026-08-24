import Cocoa
import FlutterMacOS

/// True when the system scheduler started this process for a cleanup rather
/// than a person starting it for a look.
///
/// Both signals are read because the job sets both and neither survives
/// everywhere: argv does not reach the Dart entrypoint on macOS, and the
/// environment is the awkward one to set on Windows. See `BackgroundService`
/// in the Dart sources, which is what writes the job.
let isBackgroundRun =
  ProcessInfo.processInfo.environment["KRUFTLE_BACKGROUND"] == "1"
  || CommandLine.arguments.contains("--background-clean")

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationWillFinishLaunching(_ notification: Notification) {
    // No Dock tile and no menu bar for a job nobody asked to look at. Set
    // before launching finishes, which is the last moment the activation
    // policy can change without the icon having already appeared.
    if isBackgroundRun {
      NSApp.setActivationPolicy(.accessory)
      return
    }
    applyBundleIcon()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Again, after launching. Not belt and braces for its own sake:
    // `applicationIconImage` is whatever AppKit resolved for the bundle unless
    // somebody assigns it, and what AppKit resolves depends on Launch
    // Services — an outside index that a build which has never been installed
    // is not in. Assigning at both ends of launch means the About panel and
    // the Dock tile show the icon this bundle actually carries, whichever
    // moment the resolution happened at.
    guard !isBackgroundRun else { return }
    applyBundleIcon()
  }

  /// Points the running application at the icon inside our own bundle.
  ///
  /// Two lookups, because they fail in different situations. The asset
  /// catalogue is the normal path; the `.icns` beside it still works when the
  /// catalogue was not rebuilt — which is exactly what a developer hits after
  /// changing the icon and running an incremental build.
  private func applyBundleIcon() {
    if let icon = NSImage(named: "AppIcon") {
      NSApp.applicationIconImage = icon
      return
    }
    if let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
      let icon = NSImage(contentsOf: url)
    {
      NSApp.applicationIconImage = icon
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
