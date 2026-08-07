import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Application;

class TaskerRemoteButtonDelegate extends WatchUi.BehaviorDelegate {

    // Back button manager for handling double-press logic
    var _backButtonManager as BackButtonManager;
    
    // Button constants
    const BUTTON_UP = 0;
    const BUTTON_DOWN = 1;
    const BUTTON_SELECT = 2;
    const BUTTON_BACK = 3;

    function initialize() {
        BehaviorDelegate.initialize();
        _backButtonManager = TaskerUtils.getGlobalBackButtonManager();
    }

    // Simplified button handler - single press only (except BACK for exit)
    function handleButtonPress(buttonId as Lang.Number) as Lang.Boolean {
        if (buttonId == BUTTON_BACK) {
            return handleBackButton();
        }
        
        // All other buttons: immediate single task trigger
        var taskIndex = getSingleTaskIndex(buttonId);
        if (taskIndex >= 0) {
            TaskerUtils.triggerTask(taskIndex);
        }
        
        return true;
    }
    
    // Handle BACK button with toggleable single, double, and triple press logic
    function handleBackButton() as Lang.Boolean {
        var useNewBehavior = TaskerUtils.getUseNewBackButtonBehavior();

        if (useNewBehavior) {
            // New triple-press behavior (delayed action)
            if (TaskerUtils.isTaskConfigured(14)) {
                _backButtonManager.handleBackPress(
                    method(:onBackSinglePress),
                    method(:onBackDoublePress),
                    method(:onPerformExit)
                );
            } else {
                _backButtonManager.handleBackPress(
                    method(:onBackDoublePress),
                    method(:onPerformExit),
                    method(:onPerformExit)
                );
            }
        } else {
            // Original double-press behavior (immediate action)
            _backButtonManager.handleBackPressLegacy(
                method(:onBackSinglePressLegacy),
                method(:onPerformExit)
            );
        }
        return true;
    }

    // Handle UP button press -> Task 11 (single press only)
    function onNextPage() as Lang.Boolean {
        return handleButtonPress(BUTTON_UP);
    }

    // Handle DOWN button press -> Task 12 (single press only)
    function onPreviousPage() as Lang.Boolean {
        return handleButtonPress(BUTTON_DOWN);
    }

    // Handle SELECT button press -> Task 13 (single press only)
    function onSelect() as Lang.Boolean {
        return handleButtonPress(BUTTON_SELECT);
    }

    // Handle MENU button press -> Same as UP button (Task 11)
    function onMenu() as Lang.Boolean {
        return handleButtonPress(BUTTON_UP);
    }

    // Handle BACK button press -> Task 14 (single) / Menu/Exit (double press)
    function onBack() as Lang.Boolean {
        return handleButtonPress(BUTTON_BACK);
    }

    // Single press callback for new behavior (triggers task)
    function onBackSinglePress() as Void {
        TaskerUtils.triggerTask(14);
    }

    // Single press callback for original behavior (triggers task and switches view)
    function onBackSinglePressLegacy() as Void {
        if (TaskerUtils.isTaskConfigured(14)) {
            TaskerUtils.triggerTask(14);
        }
        onBackDoublePress(); // Also switch view
    }

    // Double press callback for back button (switches to menu view)
    function onBackDoublePress() as Void {
        var disableSinglePress = TaskerUtils.getDisableSinglePress();
        if (!disableSinglePress) {
            var menuView = new TaskerRemoteMenuView();
            var menuDelegate = new TaskerRemoteMenuDelegate();
            WatchUi.switchToView(menuView, menuDelegate, WatchUi.SLIDE_RIGHT);
        }
    }

    // Get the single-press task index for a button
    function getSingleTaskIndex(buttonId as Lang.Number) as Lang.Number {
        if (buttonId == BUTTON_UP) {
            return 11; // UP button -> task_11
        } else if (buttonId == BUTTON_DOWN) {
            return 12; // DOWN button -> task_12
        } else if (buttonId == BUTTON_SELECT) {
            return 13; // SELECT button -> task_13
        }
        // BACK button is handled separately for menu/exit functionality
        return -1; // Invalid
    }

    // Wrapper for the centralized exit function
    function onPerformExit() as Void {
        TaskerUtils.performExit();
    }
}
