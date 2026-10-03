import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Application;

// Menu view for displaying available tasks
class TaskerRemoteMenuView extends WatchUi.Menu2 {
    
    // Cached menu items to avoid rebuilding
    static var _cachedMenuItems as Array<WatchUi.MenuItem>?;
    static var _menuCacheValid as Boolean = false;
    
    function initialize() {
        Menu2.initialize({});
        updateMenuItems();
    }
    
    // Invalidate menu cache (call when tasks change)
    static function invalidateMenuCache() as Void {
        _menuCacheValid = false;
        _cachedMenuItems = null;
    }
    
    // Updates the list of task menu items based on stored settings
    function updateMenuItems() {
        // Use cached menu items if available and valid
        if (_menuCacheValid && _cachedMenuItems != null) {
            for (var i = 0; i < _cachedMenuItems.size(); i++) {
                addItem(_cachedMenuItems[i]);
            }
            return;
        }
        
        // Build new menu items and cache them
        _cachedMenuItems = new Array<WatchUi.MenuItem>[0];
        var menuItemCount = 0;
        
        // Initialize task cache to use optimized task checking
        TaskerUtils.initializeTaskCache();
        
        // Task organization: Task 1 (normal menu), Tasks 2-6 (auto-exit), Tasks 7-15 (normal menu), Tasks 16-19 (button)
        // Check normal menu task 1 first
        if (TaskerUtils.isTaskConfigured(1)) {
            var taskKey = "task_1";
            // Use cached task name directly - no additional property lookup needed
            var taskName = TaskerUtils.getCachedTaskName(1);
            
            // Create menu item with just the task name - no prefixes or numbering
            var menuItem = new WatchUi.MenuItem(taskName, null, taskKey, {});
            _cachedMenuItems.add(menuItem);
            addItem(menuItem);
            menuItemCount += 1;
        }
        
        // Check auto-exit tasks 2-6
        for (var i = 2; i <= 6; i += 1) {
            if (TaskerUtils.isTaskConfigured(i)) {
                var taskKey = "task_" + i.toString();
                // Use cached task name directly - no additional property lookup needed
                var taskName = TaskerUtils.getCachedTaskName(i);
                
                // Create menu item with just the task name - no prefixes or numbering
                var menuItem = new WatchUi.MenuItem(taskName, null, taskKey, {});
                _cachedMenuItems.add(menuItem);
                addItem(menuItem);
                menuItemCount += 1;
            }
        }
        
        // Check normal menu tasks 7-15
        for (var i = 7; i <= 15; i += 1) {
            if (TaskerUtils.isTaskConfigured(i)) {
                var taskKey = "task_" + i.toString();
                // Use cached task name directly - no additional property lookup needed
                var taskName = TaskerUtils.getCachedTaskName(i);
                
                // Create menu item with just the task name - no prefixes or numbering
                var menuItem = new WatchUi.MenuItem(taskName, null, taskKey, {});
                _cachedMenuItems.add(menuItem);
                addItem(menuItem);
                menuItemCount += 1;
            }
        }
        
        _menuCacheValid = true;
    }
}

// Menu delegate for handling task selection
class TaskerRemoteMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    // Back button manager for handling double-press logic
    var _backButtonManager as BackButtonManager;
    
    function initialize() {
        Menu2InputDelegate.initialize();
        _backButtonManager = TaskerUtils.getGlobalBackButtonManager();
    }
    
    // Handle menu item selection
    function onSelect(item as WatchUi.MenuItem) as Void {
        var itemId = item.getId() as Lang.String;
        
        
        // Extract task index from the task key (e.g., "task_3" -> 3 for 1-based index)
        var taskIndexStr = itemId.substring(5, itemId.length()); // Remove "task_" prefix
        var taskIndex = taskIndexStr.toNumber(); // Use task number directly (1-based)
        
        // Check if this is an auto-exit task (2-6)
        var shouldExit = TaskerUtils.isAutoExitTask(taskIndex);
        
        // Trigger the selected task with auto-exit if applicable
        TaskerUtils.triggerTaskWithExit(taskIndex, shouldExit);
        
        // Only switch to button view if not auto-exiting
        if (!shouldExit) {
            // Check if we should switch to button view on select
            var switchOnSelect = TaskerUtils.getSwitchOnSelect();
            if (switchOnSelect) {
                var buttonView = new TaskerRemoteButtonView();
                var delegate = new TaskerRemoteButtonDelegate();
                WatchUi.switchToView(buttonView, delegate, WatchUi.SLIDE_LEFT);
            }
        }
    }
    
    // Handle back button with toggleable double-press exit
    function onBack() as Void {
        var useNewBehavior = TaskerUtils.getUseNewBackButtonBehavior();

        if (useNewBehavior) {
            // New behavior: single=switch, double=exit, triple=exit
            _backButtonManager.handleBackPress(
                method(:onBackSinglePress),
                method(:onPerformExit),
                method(:onPerformExit)
            );
        } else {
            // Original behavior: single=switch, double=exit
            _backButtonManager.handleBackPressLegacy(
                method(:onBackSinglePress),
                method(:onPerformExit)
            );
        }
    }
    
    // Single press callback for back button
    function onBackSinglePress() as Void {
        var disableSinglePress = TaskerUtils.getDisableSinglePress();
        if (!disableSinglePress) {
            // If single press is enabled, a single press on the back button will
            // switch to the button view. Using switchToView preserves the input
            // delegate's context, allowing the double-press timer to continue.
            var buttonView = new TaskerRemoteButtonView();
            var delegate = new TaskerRemoteButtonDelegate();
            WatchUi.switchToView(buttonView, delegate, WatchUi.SLIDE_LEFT);
        }
        // If single press is disabled, do nothing on a single back press.
        // The double-press exit will still work.
    }
    
    // Wrapper for the centralized exit function
    function onPerformExit() as Void {
        TaskerUtils.performExit();
    }
}
