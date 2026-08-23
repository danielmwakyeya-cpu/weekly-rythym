package com.example.keke_days_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.today_widget).apply {
                val title = widgetData.getString("widget_title", "Weekly Rhythm")
                val day = widgetData.getString("widget_day", "Today")
                val progress = widgetData.getString("widget_progress", "0 / 0 done")
                val tasks = widgetData.getString("widget_tasks", "Open app to view routine")

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_day, day)
                setTextViewText(R.id.widget_progress, progress)
                setTextViewText(R.id.widget_tasks, tasks)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
