package com.threed_print_calculator

import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import androidx.activity.result.contract.ActivityResultContracts.OpenDocument
import androidx.activity.result.contract.ActivityResultContracts.OpenMultipleDocuments
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    private var pendingPickerResult: MethodChannel.Result? = null

    private val gcodePickerLauncher =
            registerForActivityResult(OpenDocument()) { uri ->
                val result = pendingPickerResult
                pendingPickerResult = null

                if (result == null) {
                    return@registerForActivityResult
                }

                if (uri == null) {
                    result.success(null)
                    return@registerForActivityResult
                }

                runCatching {
                    contentResolver.takePersistableUriPermission(
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION,
                    )
                }

                runCatching { result.success(buildPickerPayload(uri)) }.onFailure { error ->
                    result.error("gcode_picker_failed", error.message, null)
                }
            }

    private val gcodeMultiPickerLauncher =
            registerForActivityResult(OpenMultipleDocuments()) { uris ->
                val result = pendingPickerResult
                pendingPickerResult = null

                if (result == null) return@registerForActivityResult
                if (uris.isNullOrEmpty()) {
                    result.success(emptyList<Map<String, Any?>>())
                    return@registerForActivityResult
                }

                val success = mutableListOf<Map<String, Any?>>()
                uris.forEach { uri ->
                    runCatching {
                        contentResolver.takePersistableUriPermission(
                                uri,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION,
                        )
                        success.add(buildPickerPayload(uri))
                    }
                }

                result.success(success)
            }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.threed_print_calculator/gcode_import_picker",
                )
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "pickGCodeFile" -> {
                            if (pendingPickerResult != null) {
                                result.error(
                                        "gcode_picker_busy",
                                        "Another picker request is already active.",
                                        null
                                )
                                return@setMethodCallHandler
                            }

                            pendingPickerResult = result
                            gcodePickerLauncher.launch(arrayOf("*/*"))
                        }
                        "pickGCodeFiles" -> {
                            if (pendingPickerResult != null) {
                                result.error(
                                        "gcode_picker_busy",
                                        "Another picker request is already active.",
                                        null
                                )
                                return@setMethodCallHandler
                            }

                            pendingPickerResult = result
                            gcodeMultiPickerLauncher.launch(arrayOf("*/*"))
                        }
                        else -> result.notImplemented()
                    }
                }
    }

    private fun buildPickerPayload(uri: Uri): Map<String, Any?> {
        val metadata = queryMetadata(uri)
        val displayName =
                metadata.displayName?.takeIf { it.isNotBlank() }
                        ?: "gcode-import-${System.currentTimeMillis()}"
        val cachedFile = copyUriToCache(uri, displayName)

        return mapOf(
                "displayName" to displayName,
                "originalName" to metadata.displayName,
                "mimeType" to (contentResolver.getType(uri) ?: metadata.mimeType),
                "size" to (metadata.size ?: cachedFile.length()),
                "path" to cachedFile.absolutePath,
                "uri" to uri.toString(),
        )
    }

    private fun queryMetadata(uri: Uri): PickedFileMetadata {
        var displayName: String? = null
        var size: Long? = null

        val cursor: Cursor? =
                contentResolver.query(
                        uri,
                        arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
                        null,
                        null,
                        null,
                )

        cursor?.use {
            if (it.moveToFirst()) {
                val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0 && !it.isNull(nameIndex)) {
                    displayName = it.getString(nameIndex)
                }

                val sizeIndex = it.getColumnIndex(OpenableColumns.SIZE)
                if (sizeIndex >= 0 && !it.isNull(sizeIndex)) {
                    size = it.getLong(sizeIndex)
                }
            }
        }

        return PickedFileMetadata(
                displayName = displayName,
                size = size,
                mimeType = contentResolver.getType(uri),
        )
    }

    private fun copyUriToCache(uri: Uri, displayName: String): File {
        val sanitizedName = displayName.replace(Regex("[^A-Za-z0-9._-]"), "_")
        val prefix =
                sanitizedName.substringBeforeLast('.', sanitizedName).take(32).let {
                    if (it.length < 3) "gcode_import" else it
                }
        val suffix = sanitizedName.substringAfterLast('.', "tmp").let { ".${it.take(16)}" }
        val target = File.createTempFile(prefix, suffix, cacheDir)

        contentResolver.openInputStream(uri)?.use { input ->
            target.outputStream().buffered().use { output -> input.copyTo(output) }
        }
                ?: error("Unable to open selected file.")

        return target
    }
}

private data class PickedFileMetadata(
        val displayName: String?,
        val size: Long?,
        val mimeType: String?,
)
