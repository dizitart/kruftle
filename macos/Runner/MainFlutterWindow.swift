import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // A scheduled cleanup gets no window. Windows and Linux need no equivalent
    // — both only show theirs once Flutter renders a frame, and a background
    // run never calls `runApp` — but this window comes from the nib, marked
    // visible at launch, before Dart has had a say.
    if isBackgroundRun {
      self.orderOut(nil)
    }
  }
}
