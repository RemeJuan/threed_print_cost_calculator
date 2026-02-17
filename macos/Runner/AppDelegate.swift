import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Make the application quit when its last window closes.
  /// - Parameters:
  ///   - sender: The application requesting termination behavior.
  /// - Returns: `true` if the application should terminate when the last window closes, `false` otherwise.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  /// Indicates that the application supports secure restoration of its UI state.
  /// - Parameter app: The application requesting permission to restore its state.
  /// - Returns: `true` to allow secure state restoration, `false` to disallow it.
  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}