import Flutter
import UIKit
import UniformTypeIdentifiers

public class AutoBackupPlatformPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  private var channel: FlutterMethodChannel!
  private var pickerResult: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AutoBackupPlatformPlugin()
    instance.channel = FlutterMethodChannel(name: "auto_backup_platform", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: instance.channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "pickDestination": pickDestination(result: result)
    case "verifyDestination": handleVerify(call: call, result: result)
    case "writeBackup": handleWrite(call: call, result: result)
    default: result(FlutterMethodNotImplemented)
    }
  }

  private func pickDestination(result: @escaping FlutterResult) {
    pickerResult = result
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
    picker.delegate = self
    picker.allowsMultipleSelection = false
    guard let root = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })?.rootViewController else { pickerResult?(FlutterError(code: "no_ui", message: "ui", details: nil)); return }
    root.present(picker, animated: true)
  }

  public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    pickerResult?(nil)
    pickerResult = nil
  }

  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first, let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
      pickerResult?(FlutterError(code: "pick_failed", message: "bookmark", details: nil)); pickerResult = nil; return
    }
    pickerResult?(["accessToken": data.base64EncodedString(), "displayLabel": url.lastPathComponent, "platform": "ios"])
    pickerResult = nil
  }

  private func resolveFolder(_ accessToken: String) throws -> URL {
    guard let data = Data(base64Encoded: accessToken) else { throw FlutterError(code: "invalid_token", message: "base64", details: nil) }
    var stale = false
    return try URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &stale)
  }

  private func withScopedFolder(_ accessToken: String, _ block: (URL) throws -> Void) throws {
    let url = try resolveFolder(accessToken)
    guard url.startAccessingSecurityScopedResource() else { throw FlutterError(code: "scope_failed", message: "scope", details: nil) }
    defer { url.stopAccessingSecurityScopedResource() }
    try block(url)
  }

  private func handleVerify(call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      let args = call.arguments as? [String: Any] ?? [:]
      let fileName = try validatedFileName(args["fileName"] as? String ?? "backup")
      try withScopedFolder(args["accessToken"] as? String ?? "") { folder in
        let temp = folder.appendingPathComponent(".verify_\(fileName).tmp")
        guard FileManager.default.createFile(
          atPath: temp.path,
          contents: Data([1]),
          attributes: nil,
        ) else {
          throw FlutterError(
            code: "verify_failed",
            message: "Failed to create temp file",
            details: nil,
          )
        }
        defer { try? FileManager.default.removeItem(at: temp) }
      }
      result(["ok": true, "displayLabel": (call.arguments as? [String: Any])?["displayLabel"] ?? ""])
    } catch let error as FlutterError { result(error) } catch { result(FlutterError(code: "verify_failed", message: error.localizedDescription, details: nil)) }
  }

  private func handleWrite(call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      let args = call.arguments as? [String: Any] ?? [:]
      let fileName = try validatedFileName(args["fileName"] as? String ?? "backup")
      let contents = (args["contents"] as? String ?? "").data(using: .utf8) ?? Data()
      try withScopedFolder(args["accessToken"] as? String ?? "") { folder in
        let fileURL = folder.appendingPathComponent(fileName)
        try contents.write(to: fileURL, options: .atomic)
      }
      result(["ok": true, "displayLabel": args["displayLabel"] ?? "", "fileName": fileName])
    } catch let error as FlutterError { result(error) } catch { result(FlutterError(code: "write_failed", message: error.localizedDescription, details: nil)) }
  }

  private func validatedFileName(_ fileName: String) throws -> String {
    let pattern = #"^[A-Za-z0-9._-]+$"#
    guard fileName.range(of: pattern, options: .regularExpression) != nil else {
      throw FlutterError(
        code: "invalid_filename",
        message: "fileName must use only letters, numbers, dots, hyphens, and underscores",
        details: nil,
      )
    }
    return fileName
  }
}
