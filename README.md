OttTelka_by_fld
------------------------

How to use:
1) Upload the entire repository to GitHub (push all files and folders).
2) In Codemagic, connect the repo and set Project path = . (root) and trigger a Flutter build -> Android (APK).
3) After build finishes, download app-debug.apk from Artifacts.

Notes:
- Uses video_player for DASH playback.
- Player opens inside app and tapping the video switches to fullscreen.
