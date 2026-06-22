import Flutter
import UIKit
import UniformTypeIdentifiers

private struct PluginError: Error {
  let code: String
  let message: String

  func asFlutterError() -> FlutterError {
    FlutterError(code: code, message: message, details: nil)
  }
}

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
    guard let url = urls.first,
          let data = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) else {
      pickerResult?(FlutterError(code: "pick_failed", message: "bookmark", details: nil)); pickerResult = nil; return
    }
    pickerResult?(["accessToken": data.base64EncodedString(), "displayLabel": url.lastPathComponent, "platform": "ios"])
    pickerResult = nil
  }

  private func resolveFolder(_ accessToken: String) throws -> URL {
    guard let data = Data(base64Encoded: accessToken) else {
      throw PluginError(code: "invalid_token", message: "base64")
    }
    var stale = false
    return try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &stale)
  }

  private func withScopedFolder(_ accessToken: String, _ block: (URL) throws -> Void) throws {
    let url = try resolveFolder(accessToken)
    guard url.startAccessingSecurityScopedResource() else {
      throw PluginError(code: "scope_failed", message: "scope")
    }
    defer { url.stopAccessingSecurityScopedResource() }
    try block(url)
  }

  private func handleVerify(call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      let args = call.arguments as? [String: Any] ?? [:]
      let fileName = try validatedFileName(args["fileName"] as? String ?? "backup")
      try withScopedFolder(args["accessToken"] as? String ?? "") { folder in
        let temp = folder.appendingPathComponent(".verify_\(fileName)_\(UUID().uuidString).tmp")
        guard FileManager.default.createFile(
          atPath: temp.path,
          contents: Data([1]),
          attributes: nil,
        ) else {
          throw PluginError(code: "verify_failed", message: "Failed to create temp file")
        }
        defer { try? FileManager.default.removeItem(at: temp) }
      }
      result(["ok": true, "displayLabel": (call.arguments as? [String: Any])?["displayLabel"] ?? ""])
    } catch let error as PluginError {
      result(error.asFlutterError())
    } catch {
      result(FlutterError(code: "verify_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func handleWrite(call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      let args = call.arguments as? [String: Any] ?? [:]
      let fileName = try validatedFileName(args["fileName"] as? String ?? "backup")
      guard let rawContents = args["contents"] as? String, !rawContents.isEmpty else {
        throw PluginError(code: "missing_contents", message: "Backup contents is missing or empty")
      }
      guard let contents = rawContents.data(using: .utf8) else {
        throw PluginError(code: "invalid_contents", message: "contents must be valid UTF-8")
      }
      try withScopedFolder(args["accessToken"] as? String ?? "") { folder in
        let fileURL = folder.appendingPathComponent(fileName)
        let tempURL = folder.appendingPathComponent(".\(fileName).\(UUID().uuidString).tmp")
        defer { try? FileManager.default.removeItem(at: tempURL) }
        guard FileManager.default.createFile(
          atPath: tempURL.path,
          contents: contents,
          attributes: nil
        ) else {
          throw PluginError(code: "write_failed", message: "Failed to create file")
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
          // Atomic replace when target already exists.
          _ = try FileManager.default.replaceItemAt(
            fileURL,
            withItemAt: tempURL,
            backupItemName: nil,
            options: []
          )
        } else {
          try FileManager.default.moveItem(at: tempURL, to: fileURL)
        }
      }
      result(["ok": true, "displayLabel": args["displayLabel"] ?? "", "fileName": fileName])
    } catch let error as PluginError {
      result(error.asFlutterError())
    } catch {
      result(FlutterError(code: "write_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func validatedFileName(_ fileName: String) throws -> String {
    guard fileName != ".", fileName != ".." else {
      throw PluginError(
        code: "invalid_filename",
        message: "fileName cannot be '.' or '..'",
      )
    }
    let pattern = #"^[A-Za-z0-9._-]+$"#
    guard fileName.range(of: pattern, options: .regularExpression) != nil else {
      throw PluginError(
        code: "invalid_filename",
        message: "fileName must use only letters, numbers, dots, hyphens, and underscores",
      )
    }
    return fileName
  }
}
