package org.quranflutter.quran_flutter

import com.ryanheise.audioservice.AudioServiceActivity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    private var documentExport: LocalDocumentExport? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        documentExport = LocalDocumentExport(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    @Deprecated("Deprecated by Android; retained for AudioServiceActivity compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (documentExport?.onActivityResult(requestCode, resultCode, data) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        documentExport?.dispose()
        documentExport = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
