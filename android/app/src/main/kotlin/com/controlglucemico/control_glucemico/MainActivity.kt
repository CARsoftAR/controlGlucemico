package com.controlglucemico.control_glucemico

import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.controlglucemico/whatsapp_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sharePdfToWhatsApp") {
                    val filePath = call.argument<String>("filePath")
                    val phone = call.argument<String>("phone")
                    val text = call.argument<String>("text") ?: ""

                    if (filePath.isNullOrEmpty() || phone.isNullOrEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    try {
                        val file = File(filePath)
                        if (!file.exists()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        val authority = "${applicationContext.packageName}.gluco_fileprovider"
                        val contentUri: Uri = FileProvider.getUriForFile(this, authority, file)

                        val pm = packageManager
                        val targetPackage = when {
                            isPackageInstalled("com.whatsapp", pm) -> "com.whatsapp"
                            isPackageInstalled("com.whatsapp.w4b", pm) -> "com.whatsapp.w4b"
                            else -> null
                        }

                        if (targetPackage != null) {
                            grantUriPermission(
                                targetPackage,
                                contentUri,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION
                            )

                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "application/pdf"
                                `package` = targetPackage
                                putExtra(Intent.EXTRA_STREAM, contentUri)
                                putExtra(Intent.EXTRA_TEXT, text)
                                putExtra("jid", "$phone@s.whatsapp.net")
                                clipData = ClipData.newRawUri("", contentUri)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }

                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun isPackageInstalled(packageName: String, packageManager: PackageManager): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}
