import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;


class TaskerRemoteApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        // Check if user wants to launch directly into buttons view
        var launchButtonsDirectly = Application.Properties.getValue("launch_buttons_directly");
        if (launchButtonsDirectly == true) {
            // Launch directly into buttons view
            var buttonView = new TaskerRemoteButtonView();
            var delegate = new TaskerRemoteButtonDelegate();
            return [buttonView, delegate];
        }
        
        // Default: start with menu view - simple and stable
        var menuView = new TaskerRemoteMenuView();
        var menuDelegate = new TaskerRemoteMenuDelegate();
        return [menuView, menuDelegate];
    }

    // onSettingsChanged() is called when the settings are changed
    function onSettingsChanged() as Void {
        // Refresh task cache when settings change
        TaskerUtils.refreshTaskCache();
        // Invalidate menu cache to rebuild with new task data
        TaskerRemoteMenuView.invalidateMenuCache();
        // Request a screen update so changes are shown
        WatchUi.requestUpdate();
    }

    // getGlanceView() is called to return the glance view and its delegate
    function getGlanceView() {
        return [ new TaskerRemoteGlanceView(), new TaskerRemoteGlanceDelegate() ];
    }

    // --------------------------
    //      Helper Methods
    // --------------------------

    // Memory-optimized trim function - uses substring operations instead of char arrays
    function trimString(str as String?) as String {
        if (str == null || str.length() == 0) {
            return "";
        }
        
        var len = str.length();
        var start = 0;
        var end = len;
        
        // Find first non-whitespace by checking substrings
        while (start < len) {
            var c = str.substring(start, start + 1);
            if (!c.equals(" ") && !c.equals("\n") && !c.equals("\t") && !c.equals("\r")) {
                break;
            }
            start++;
        }
        
        // Find last non-whitespace
        while (end > start) {
            var c = str.substring(end - 1, end);
            if (!c.equals(" ") && !c.equals("\n") && !c.equals("\t") && !c.equals("\r")) {
                break;
            }
            end--;
        }
        
        return (start >= end) ? "" : str.substring(start, end);
    }
}
