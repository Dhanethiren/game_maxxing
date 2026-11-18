package com.gamemaxxing.calm_grid

import android.app.Application
import android.content.Context
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter

/**
 * Records any uncaught Java/Kotlin crash (including ones inside the ads SDK
 * during start-up) to a file, so [MainActivity] can show it on the next launch.
 */
class CalmGridApplication : Application() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                val trace = StringWriter().also { error.printStackTrace(PrintWriter(it)) }
                File(base.filesDir, CRASH_FILE).writeText("Thread: ${thread.name}\n$trace")
            } catch (_: Throwable) {
                // Never let the crash reporter itself crash.
            }
            previous?.uncaughtException(thread, error)
        }
    }

    companion object {
        const val CRASH_FILE = "last_crash.txt"
    }
}
