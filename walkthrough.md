# Verification & Walkthrough

I have implemented the feature to show the student's assigned bus stop on the live tracking map, making the system **highly robust** against inconsistent data formats.

## Changes Made

1.  **New Model**: Created `StopModel` (`lib/models/stop_model.dart`) that gracefully parses `lat` and `long` even if they are stored as **Strings** in the database.
2.  **Updated Student Model**: Modified `StudentModel` to include `busStopId`.
3.  **Repository Update**: 
    - Added `getStop` (by ID).
    - Added `getStopByName` (by Name fallback).
    - **[NEW]** Added `findStopByStudent` to search for the stop where the student's ID/Roll No is listed in the `assigned_students` array.
4.  **Service Update**: Exposed all methods via `DatabaseService`.
5.  **Map Screen**: Updated `MapScreen` (`lib/screens/map_screen.dart`) to attempt 3 lookups in order:
    1.  **By ID**: Uses `bus_stop_id` if present in the student profile.
    2.  **By Name**: Uses `bus_stop` name if present.
    3.  **By Assignment**: Queries the stops collection to find where the student is assigned.

## How to Test

1.  Login to the Student App as a student.
2.  Navigate to the **Live Bus Location** screen.
3.  The app will automatically find your stop, regardless of whether your profile has the exact ID link or if you are just in the legacy `assigned_students` list.
4.  You should see the **Red Location Pin** on the map.

## Verification Checklist

- [x] `StopModel` parses String coordinates ("12.12008").
- [x] `StudentModel` reads `bus_stop_id`.
- [x] `getStop` fetches data by ID.
- [x] `getStopByName` fetches data by Name.
- [x] `findStopByStudent` queries `assigned_students` array.
- [x] `MapScreen` implements the multi-step fallback logic.
- [x] Map displays both Bus and Stop markers correctly.
