package com.threedprintcostcalculator.auto_backup_platform

import android.app.Activity
import android.content.Context
import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.FileNotFoundException

class AutoBackupPlatformPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var resolver: ContentResolver
  private lateinit var context: Context
  private var activity: Activity? = null
  private var pendingResult: MethodChannel.Result? = null
  private var activityBinding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "auto_backup_platform")
    channel.setMethodCallHandler(this)
    context = binding.applicationContext
    resolver = context.contentResolver
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "pickDestination" -> pickDestination(result)
      "verifyDestination" -> verifyDestination(call, result)
      "writeBackup" -> writeBackup(call, result)
      else -> result.notImplemented()
    }
  }

  private fun pickDestination(result: MethodChannel.Result) {
    val activity = activity ?: run {
      result.error("no_activity", "Activity required", null)
      return
    }
    if (pendingResult != null) {
      pendingResult!!.error("pending", "A destination pick is already in progress", null)
      pendingResult = null
    }
    pendingResult = result
    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
      addFlags(
        Intent.FLAG_GRANT_READ_URI_PERMISSION or
          Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
          Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
          Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
      )
    }
    activity.startActivityForResult(intent, 9011)
  }

  private fun verifyDestination(call: MethodCall, result: MethodChannel.Result) {
    try {
      val tree = Uri.parse(call.argument<String>("accessToken"))
      val dir = DocumentFile.fromTreeUri(context, tree)
        ?: throw FileNotFoundException("Destination not found")
      val fileName = requireSimpleFileName(call.argument<String>("fileName") ?: "backup")
      val tempName = ".verify_${fileName}.tmp"
      val temp = dir.createFile("application/octet-stream", tempName)
        ?: throw FileNotFoundException("Unable to create temp file")
      try {
        resolver.openOutputStream(temp.uri)?.use { it.write(byteArrayOf(1)) }
          ?: throw FileNotFoundException("Unable to open temp file")
      } finally {
        temp.delete()
      }
      result.success(mapOf("ok" to true, "displayLabel" to call.argument<String>("displayLabel")))
    } catch (e: Exception) {
      result.error("verify_failed", e.message, null)
    }
  }

  private fun writeBackup(call: MethodCall, result: MethodChannel.Result) {
    try {
      val tree = Uri.parse(call.argument<String>("accessToken"))
      val dir = DocumentFile.fromTreeUri(context, tree)
        ?: throw FileNotFoundException("Destination not found")
      val fileName = requireSimpleFileName(
        call.argument<String>("fileName") ?: throw IllegalArgumentException("fileName")
      )
      val existing = dir.findFile(fileName)
      existing?.delete()
      val file = dir.createFile("application/octet-stream", fileName)
        ?: throw FileNotFoundException("Unable to create file")
      val contents = call.argument<String>("contents") ?: ""
      resolver.openOutputStream(file.uri, "w")?.use { it.write(contents.toByteArray()) }
        ?: throw FileNotFoundException("Unable to write file")
      result.success(mapOf("ok" to true, "displayLabel" to call.argument<String>("displayLabel"), "fileName" to fileName))
    } catch (e: Exception) {
      result.error("write_failed", e.message, null)
    }
  }

  private fun requireSimpleFileName(fileName: String): String {
    if (!SIMPLE_FILE_NAME.matches(fileName)) {
      throw IllegalArgumentException(
        "Invalid fileName: use only letters, numbers, dots, hyphens, and underscores"
      )
    }
    return fileName
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityBinding?.removeActivityResultListener(this)
    activityBinding = null
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { onAttachedToActivity(binding) }

  override fun onDetachedFromActivity() {
    activityBinding?.removeActivityResultListener(this)
    activityBinding = null
    activity = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode != 9011) return false
    val result = pendingResult ?: return true
    pendingResult = null
    if (resultCode != Activity.RESULT_OK || data?.data == null) {
      result.success(null)
      return true
    }
    val uri = data.data!!
    val flags = data.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
    try {
      resolver.takePersistableUriPermission(uri, flags)
    } catch (e: SecurityException) {
      result.error("permission_failed", "Failed to persist URI permission: ${e.message}", null)
      return
    }
    result.success(mapOf("accessToken" to uri.toString(), "displayLabel" to (DocumentFile.fromTreeUri(context, uri)?.name ?: ""), "platform" to "android"))
    return true
  }

  companion object {
    private val SIMPLE_FILE_NAME = Regex("^[A-Za-z0-9._-]+$")
  }
}
