package com.boris.pora

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget PORA. Читает данные, записанные из Dart
 * (`HomeWidgetService`): `pora_needed_count` (Int) и `pora_needed_items`
 * (String, позиции через \n), и рисует их в layout `res/layout/pora_widget.xml`.
 *
 * Подключается через <receiver> в AndroidManifest + `res/xml/pora_widget_info.xml`.
 * home_widget предоставляет widgetData (SharedPreferences) в onUpdate.
 */
class PoraWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.pora_widget)

            val count = widgetData.getInt("pora_needed_count", 0)
            val items = widgetData.getString("pora_needed_items", "") ?: ""

            views.setTextViewText(
                R.id.widget_title,
                if (count > 0) "PORA · списков: $count" else "PORA"
            )
            views.setTextViewText(
                R.id.widget_body,
                if (items.isBlank()) "Нет активных списков" else items
            )

            // Тап по виджету открывает приложение.
            val pendingIntent = HomeWidgetPlugin.getBackgroundIntent(
                context,
                android.net.Uri.parse("pora://widget")
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
