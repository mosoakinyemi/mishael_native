package com.mishael_native;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.Calendar;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.TimeZone;

import android.Manifest;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.provider.CalendarContract.Calendars;
import android.provider.CalendarContract.Events;

public class CalendarModule extends ReactContextBaseJavaModule {
    private final ReactApplicationContext reactContext;

    public static final String[] EVENT_PROJECTION = new String[]{
            Calendars._ID,                           // 0
            Calendars.ACCOUNT_NAME,                  // 1
            Calendars.CALENDAR_DISPLAY_NAME,         // 2
            Calendars.OWNER_ACCOUNT                  // 3
    };

    // The indices for the projection array above.
    private static final int PROJECTION_ID_INDEX = 0;
    private static final int PROJECTION_ACCOUNT_NAME_INDEX = 1;
    private static final int PROJECTION_DISPLAY_NAME_INDEX = 2;
    private static final int PROJECTION_OWNER_ACCOUNT_INDEX = 3;

    public CalendarModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "CalendarModule";
    }

    public static boolean hasPermissions(Context context, String... permissions) {
        if (context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
    }

    public void requestCalendarPermissions() {
        int PERMISSION_ALL = 1;
        String[] PERMISSIONS = {
                android.Manifest.permission.READ_CALENDAR,
                android.Manifest.permission.WRITE_CALENDAR,
        };

        if (!hasPermissions(getCurrentActivity(), PERMISSIONS)) {
            ActivityCompat.requestPermissions(getCurrentActivity(), PERMISSIONS, PERMISSION_ALL);
        }
    }

    private boolean hasCalendarPermissions(boolean isReadOnly) {
        int writePermission = ContextCompat.checkSelfPermission(reactContext, Manifest.permission.WRITE_CALENDAR);
        int readPermission = ContextCompat.checkSelfPermission(reactContext, Manifest.permission.READ_CALENDAR);

        if (isReadOnly) {
            return readPermission == PackageManager.PERMISSION_GRANTED;
        }

        return writePermission == PackageManager.PERMISSION_GRANTED &&
                readPermission == PackageManager.PERMISSION_GRANTED;
    }

    public void checkCalendarPermission() {

        if (ActivityCompat.checkSelfPermission(getCurrentActivity(), Manifest.permission.WRITE_CALENDAR) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(getCurrentActivity(), new String[]{Manifest.permission.WRITE_CALENDAR}, PackageManager.PERMISSION_GRANTED);
        }
    }



    @ReactMethod
    public void createCalendarEvent(String title, String location) {
        if (this.hasCalendarPermissions(false)) {
            Log.i("CalendarModule", "HAS PERMISSIONS");
            long calID = 1;
            long startMillis = 0;
            long endMillis = 0;
            Calendar beginTime = Calendar.getInstance();
            beginTime.set(2021, 8, 14, 7, 30);
            startMillis = beginTime.getTimeInMillis();
            Calendar endTime = Calendar.getInstance();
            endTime.set(2021, 8, 14, 8, 45);
            endMillis = endTime.getTimeInMillis();

            ContentResolver cr = (ContentResolver) reactContext.getContentResolver();
            ContentValues values = new ContentValues();
            values.put(Events.DTSTART, startMillis);
            values.put(Events.DTEND, endMillis);
            values.put(Events.TITLE, "Jazzercise");
            values.put(Events.DESCRIPTION, "Group workout");
            values.put(Events.CALENDAR_ID, calID);
            values.put(Events.EVENT_TIMEZONE, "America/Los_Angeles");
            Uri uri = cr.insert(Events.CONTENT_URI, values);

            long eventID = Long.parseLong(uri.getLastPathSegment());
            System.out.println("Event ID [" + eventID + "]");
            return;
        } else {
            Log.i("CalendarModule", "NO PERMISSIONS BOY");
            this.requestCalendarPermissions();
            return;
        }
    }


    public void getDataFromEventTable() {
        Log.i("CalendarModule", "FEtching Saved Calendar Events2");

        Cursor cur = null;
        ContentResolver cr = getCurrentActivity().getContentResolver();
        ;

        String[] mProjection =
                {
                        "_id",
                        CalendarContract.Events.TITLE,
                        CalendarContract.Events.EVENT_LOCATION,
                        CalendarContract.Events.DTSTART,
                        CalendarContract.Events.DTEND,
                };

        Uri uri = CalendarContract.Events.CONTENT_URI;
        String selection = Events.EVENT_TIMEZONE + " = ? ";
        String[] selectionArgs = new String[]{"America/Los_Angeles"};

        cur = cr.query(uri, mProjection, selection, selectionArgs, null);

        while (cur.moveToNext()) {
            String title = cur.getString(cur.getColumnIndex(CalendarContract.Events.TITLE));
            String location = cur.getString(cur.getColumnIndex(Events.EVENT_LOCATION));

            Log.d("MY_APP", String.format("%s %s", title, location));

        }

    }


    @ReactMethod
    public void fetchCalendarEvents() {
        Log.i("CalendarModule", "FEtching Saved Calendar Events");
        this.getDataFromEventTable();
    }

    public void printContentValues(ContentValues vals) {
        Set<Map.Entry<String, Object>> s = vals.valueSet();
        Iterator itr = s.iterator();

        Log.d("DatabaseSync", "ContentValue Length :: " + vals.size());

        while (itr.hasNext()) {
            Map.Entry me = (Map.Entry) itr.next();
            String key = me.getKey().toString();
            Object value = me.getValue();

            Log.d("DatabaseSync", "Key:" + key + ", values:" + (String) (value == null ? null : value.toString()));
        }
    }
}
