package org.quranflutter.quran_flutter

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** Narrow user-mediated export. No broad/persistent storage permission. */
class LocalDocumentExport(private val activity: Activity, messenger: BinaryMessenger) {
    companion object {
        private const val REQUEST_CREATE = 0x5148
        private const val JSON_LIMIT = 5 * 1024 * 1024
        private const val IMAGE_LIMIT = 32 * 1024 * 1024
    }
    private data class Pending(val bytes: ByteArray, val result: MethodChannel.Result)
    private val channel = MethodChannel(messenger, "org.quranhaven/local_documents")
    private val writer = Executors.newSingleThreadExecutor()
    private var pending: Pending? = null
    private var disposed = false

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "save") {
                result.notImplemented()
            } else if (pending != null) {
                result.error("save_busy", "A local save is already open", null)
            } else {
                val bytes = call.argument<ByteArray>("bytes")
                val name = call.argument<String>("name")
                val mime = call.argument<String>("mime")
                val validName = name != null && name.matches(Regex("^[A-Za-z0-9][A-Za-z0-9._ -]{0,127}\\.(json|png)$"))
                val validType = (mime == "application/json" && name?.endsWith(".json") == true && bytes != null && bytes.isNotEmpty() && bytes.size <= JSON_LIMIT) ||
                    (mime == "image/png" && name?.endsWith(".png") == true && bytes != null && bytes.size in 32..IMAGE_LIMIT && bytes.take(8) == listOf(137.toByte(), 80.toByte(), 78.toByte(), 71.toByte(), 13.toByte(), 10.toByte(), 26.toByte(), 10.toByte()))
                if (!validName || !validType || bytes == null) {
                    result.error("save_invalid", "Invalid local export", null)
                } else {
                    pending = Pending(bytes, result)
                    try {
                        // ACTION_CREATE_DOCUMENT never overwrites an existing file;
                        // the document provider chooses a fresh name on collision.
                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = mime
                            putExtra(Intent.EXTRA_TITLE, name)
                            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                        }
                        @Suppress("DEPRECATION")
                        activity.startActivityForResult(intent, REQUEST_CREATE)
                    } catch (_: Exception) {
                        pending = null
                        result.error("save_unavailable", "The document chooser is unavailable", null)
                    }
                }
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CREATE) return false
        val current = pending ?: return true
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            pending = null
            current.result.success(false)
            return true
        }
        if (uri.scheme != "content") {
            pending = null
            current.result.error("save_invalid", "The selected document is unavailable", null)
            return true
        }
        writer.execute {
            val completed = try {
                activity.contentResolver.openOutputStream(uri, "w")?.use { output ->
                    output.write(current.bytes)
                    output.flush()
                } ?: throw IllegalStateException("No document stream")
                true
            } catch (_: Exception) { false }
            activity.runOnUiThread {
                if (!disposed && pending === current) {
                    pending = null
                    if (completed) current.result.success(true)
                    else current.result.error("save_failed", "Could not save the local file", null)
                }
            }
        }
        return true
    }

    fun dispose() {
        disposed = true
        channel.setMethodCallHandler(null)
        pending?.result?.success(false)
        pending = null
        writer.shutdownNow()
    }
}
