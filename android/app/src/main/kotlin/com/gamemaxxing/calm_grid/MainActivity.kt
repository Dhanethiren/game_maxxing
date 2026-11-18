package com.gamemaxxing.calm_grid

import android.app.ActivityManager
import android.app.AlertDialog
import android.app.ApplicationExitInfo
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.widget.ScrollView
import android.widget.TextView
import io.flutter.embedding.android.FlutterActivity
import java.io.File
import java.util.Date

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            collectCrashReport()?.let(::showCrashReport)
        } catch (_: Throwable) {
            // Diagnostics must never stop the game from starting.
        }
    }

    /** Crash details from the previous run, or null if it ended normally. */
    private fun collectCrashReport(): String? {
        val parts = mutableListOf<String>()

        val file = File(filesDir, CalmGridApplication.CRASH_FILE)
        if (file.exists()) {
            parts += file.readText()
            file.delete()
        }

        // Android 11+ also remembers native crashes, freezes (ANR) and crashes
        // from older installs of this app.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val prefs = getSharedPreferences("crash_reporter", MODE_PRIVATE)
            val lastSeen = prefs.getLong("lastSeen", 0)
            val am = getSystemService(ActivityManager::class.java)
            val infos = am.getHistoricalProcessExitReasons(packageName, 0, 5)
            val interesting = setOf(
                ApplicationExitInfo.REASON_CRASH,
                ApplicationExitInfo.REASON_CRASH_NATIVE,
                ApplicationExitInfo.REASON_ANR,
                ApplicationExitInfo.REASON_INITIALIZATION_FAILURE,
            )
            for (info in infos) {
                if (info.timestamp <= lastSeen || info.reason !in interesting) continue
                parts += "Exit reason ${info.reason} at ${Date(info.timestamp)}\n${info.description ?: ""}"
            }
            val newest = infos.maxOfOrNull { it.timestamp } ?: lastSeen
            prefs.edit().putLong("lastSeen", maxOf(newest, lastSeen)).apply()
        }

        if (parts.isEmpty()) return null
        return "Device: ${Build.MANUFACTURER} ${Build.MODEL}, Android ${Build.VERSION.RELEASE} " +
            "(API ${Build.VERSION.SDK_INT}), ABIs ${Build.SUPPORTED_ABIS.joinToString()}\n\n" +
            parts.joinToString("\n\n").take(6000)
    }

    private fun showCrashReport(report: String) {
        val text = TextView(this).apply {
            this.text = report
            setTextIsSelectable(true)
            textSize = 11f
            setPadding(48, 24, 48, 24)
        }
        AlertDialog.Builder(this)
            .setTitle("Calm Grid closed unexpectedly last time")
            .setView(ScrollView(this).apply { addView(text) })
            .setPositiveButton("Share report") { _, _ ->
                val send = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, report)
                }
                startActivity(Intent.createChooser(send, "Share crash report"))
            }
            .setNegativeButton("Close", null)
            .show()
    }
}
