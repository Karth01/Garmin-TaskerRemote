import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;
import Toybox.Attention;

// Shared utility class for common task operations
class TaskerUtils {
    
    // Cached task data to avoid repeated property lookups (expanded to 14 tasks)
    static var _cachedTasks as Array<String>?;
    static var _cacheInitialized as Boolean = false;
    
    // Cached settings to avoid repeated property lookups
    static var _cachedDisableVibration as Boolean = false;
    static var _cachedUseNewBackButtonBehavior as Boolean = false;
    static var _cachedDisableSinglePress as Boolean = false;
    static var _cachedSwitchOnSelect as Boolean = false;
    static var _settingsCacheInitialized as Boolean = false;
    
    // Global back button manager that persists across view transitions
    static var _globalBackButtonManager as BackButtonManager?;
    
    // Initialize task cache to reduce property lookups
    static function initializeTaskCache() as Void {
        if (_cacheInitialized) {
            return;
        }
        
        _cachedTasks = new Array<String>[15]; // Index 0 unused, 1-14 align with task numbers
        _cachedTasks[0] = ""; // Unused slot to align indices with task numbers
        for (var i = 1; i <= 14; i++) {
            var taskKey = "task_" + i.toString();
            var taskName = Application.Properties.getValue(taskKey);
            if (taskName != null) {
                taskName = (Application.getApp() as TaskerRemoteApp).trimString(taskName);
            }
            _cachedTasks[i] = (taskName != null && taskName.length() > 0) ? taskName : "";
        }
        _cacheInitialized = true;
    }
    
    // Refresh cache when settings change
    static function refreshTaskCache() as Void {
        _cacheInitialized = false;
        _settingsCacheInitialized = false; // Also refresh settings cache
        initializeTaskCache();
    }
    
    // Initialize settings cache to reduce property lookups
    static function initializeSettingsCache() as Void {
        if (_settingsCacheInitialized) {
            return;
        }
        
        var disableVibration = Application.Properties.getValue("disable_vibration");
        var useNewBehavior = Application.Properties.getValue("useNewBackButtonBehavior");
        var disableSinglePress = Application.Properties.getValue("disable_single_press");
        var switchOnSelect = Application.Properties.getValue("switch_on_select");
        
        _cachedDisableVibration = (disableVibration == true); // Default to false
        _cachedUseNewBackButtonBehavior = (useNewBehavior == true); // Default to false
        _cachedDisableSinglePress = (disableSinglePress == true); // Default to false
        _cachedSwitchOnSelect = (switchOnSelect == true); // Default to false
        _settingsCacheInitialized = true;
    }
    
    // Getter functions for cached settings to avoid direct property access
    static function getDisableVibration() as Boolean {
        initializeSettingsCache();
        return _cachedDisableVibration;
    }
    
    static function getUseNewBackButtonBehavior() as Boolean {
        initializeSettingsCache();
        return _cachedUseNewBackButtonBehavior;
    }
    
    static function getDisableSinglePress() as Boolean {
        initializeSettingsCache();
        return _cachedDisableSinglePress;
    }
    
    static function getSwitchOnSelect() as Boolean {
        initializeSettingsCache();
        return _cachedSwitchOnSelect;
    }
    
    // Helper function to execute a task request and provide feedback
    static function executeTaskRequest(taskName as String) as Void {
        var url = "http://" + taskName;
        Communications.openWebPage(url, {}, {});
        
        // Provide vibration feedback to confirm task was sent (unless disabled)
        if (!getDisableVibration() && Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(50, 200)]; // 50% intensity, 200ms pulse
            Attention.vibrate(vibeData);
        }
    }

    // Trigger a task by its index (0-13)
    // Returns true if task was triggered successfully, false otherwise
    static function triggerTask(taskIndex as Lang.Number) as Lang.Boolean {
        initializeTaskCache();
        
        if (taskIndex < 1 || taskIndex > 14 || _cachedTasks == null) {
            return false;
        }
        
        var taskName = _cachedTasks[taskIndex];
        if (taskName.length() > 0) {
            executeTaskRequest(taskName);
            return true;
        }
        return false;
    }
    
    // Find and trigger the first available configured task (for glance view)
    // Returns true if a task was found and triggered, false otherwise
    static function triggerFirstAvailableTask() as Lang.Boolean {
        initializeTaskCache();
        
        if (_cachedTasks == null) {
            return false;
        }
        
        // Find the first configured task using cached data
        for (var i = 1; i <= 14; i++) {
            var taskName = _cachedTasks[i];
            if (taskName.length() > 0) {
                executeTaskRequest(taskName);
                return true;
            }
        }
        return false;
    }
    
    // Check if a task is configured (has non-empty value)
    static function isTaskConfigured(taskIndex as Lang.Number) as Lang.Boolean {
        if (taskIndex < 1 || taskIndex > 14) {
            return false;
        }
        
        initializeTaskCache();
        
        if (_cachedTasks == null) {
            return false;
        }
        
        return _cachedTasks[taskIndex].length() > 0;
    }
    
    // Get cached task name directly (for menu optimization)
    static function getCachedTaskName(taskIndex as Lang.Number) as String {
        if (taskIndex < 1 || taskIndex > 14) {
            return "";
        }
        
        initializeTaskCache();
        
        if (_cachedTasks == null) {
            return "";
        }
        
        return _cachedTasks[taskIndex];
    }
    
    // Centralized exit function to ensure consistent behavior
    static function performExit() as Void {
        // Get the global back button manager and clean it up
        var manager = getGlobalBackButtonManager();
        if (manager != null) {
            manager.cleanup();
        }
        // Exit the current view
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Back button timer management - global instance that persists across views
    static function getGlobalBackButtonManager() as BackButtonManager {
        if (_globalBackButtonManager == null) {
            _globalBackButtonManager = new BackButtonManager();
            _globalBackButtonManager.initialize();
        }
        return _globalBackButtonManager;
    }
}

// Global back button manager that persists across view transitions
class BackButtonManager {
    var _backPressCount as Lang.Number = 0;
    var _backTimer as Timer.Timer?;
    var _doublePressCallback as Method?;
    var _triplePressCallback as Method?;
    var _singlePressCallback as Method?;

    function initialize() {
        _backTimer = null;
        _backPressCount = 0;
        _doublePressCallback = null;
        _triplePressCallback = null;
        _singlePressCallback = null;
    }

    // Handle back button press with single, double, and triple press callbacks
    function handleBackPress(singlePressCallback as Method, doublePressCallback as Method, triplePressCallback as Method) as Void {
        _backPressCount++;

        if (_backPressCount == 1) {
            // First press: store callbacks and start a timer
            _singlePressCallback = singlePressCallback;
            _doublePressCallback = doublePressCallback;
            _triplePressCallback = triplePressCallback;
            _backTimer = new Timer.Timer();
            _backTimer.start(method(:onBackTimerExpired), 500, false);
        } else if (_backPressCount == 2) {
            // Second press: do nothing, just wait for the timer
        } else if (_backPressCount >= 3) {
            // Third press: invoke triple press callback immediately and clean up
            cleanup();
            triplePressCallback.invoke();
        }
    }

    // Legacy handler for original back button behavior (immediate single press)
    function handleBackPressLegacy(singlePressCallback as Method, doublePressCallback as Method) as Void {
        _backPressCount++;

        if (_backPressCount == 1) {
            // First press: invoke single press action immediately and start a timer
            singlePressCallback.invoke();
            _doublePressCallback = doublePressCallback;
            _backTimer = new Timer.Timer();
            _backTimer.start(method(:onBackTimerExpiredLegacy), 500, false);
        } else if (_backPressCount >= 2) {
            // Second press: invoke double press action and clean up
            cleanup();
            doublePressCallback.invoke();
        }
    }

    // Timer callback for new behavior - executes the correct action based on press count
    function onBackTimerExpired() as Void {
        var cb = null;
        if (_backPressCount == 1) {
            cb = _singlePressCallback;
        } else if (_backPressCount == 2) {
            cb = _doublePressCallback;
        }

        cleanup();

        if (cb != null) {
            cb.invoke();
        }
    }

    // Timer callback for legacy behavior
    function onBackTimerExpiredLegacy() as Void {
        // In the legacy implementation, the single press has already fired.
        // This timer expiring simply means a double press did not occur.
        cleanup();
    }
    
    // Check if we're currently in double press detection window
    function isInDoublePressWindow() as Lang.Boolean {
        return _backTimer != null && _backPressCount > 0;
    }
    
    // Clean up timer resources
    function cleanup() as Void {
        if (_backTimer != null) {
            _backTimer.stop();
            _backTimer = null;
        }
        _backPressCount = 0;
        _singlePressCallback = null;
        _doublePressCallback = null;
        _triplePressCallback = null;
    }
}
