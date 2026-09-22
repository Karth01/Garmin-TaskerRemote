import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Application;

class TaskerRemoteButtonView extends WatchUi.View {


    function initialize() {
        View.initialize();
    }


    // onLayout() is called to set the layout of the view
    function onLayout(dc) {
    }

    // onUpdate() is called to update the view
    function onUpdate(dc) {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Draw button assignments in 2x2 square grid layout
        var gridSpacing = 30;
        var leftX = centerX - gridSpacing;
        var rightX = centerX + gridSpacing;
        var topY = centerY - gridSpacing;
        var bottomY = centerY + gridSpacing;
        
        // UP button -> Task 17 (top left)
        var upTaskName = getTaskName(17);
        dc.drawText(leftX, topY, Graphics.FONT_LARGE, upTaskName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // SELECT button -> Task 18 (top right)
        var selectTaskName = getTaskName(18);
        dc.drawText(rightX, topY, Graphics.FONT_LARGE, selectTaskName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // DOWN button -> Task 16 (bottom left)
        var downTaskName = getTaskName(16);
        dc.drawText(leftX, bottomY, Graphics.FONT_LARGE, downTaskName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // BACK button -> Task 19 (bottom right)
        var backTaskName = getTaskName(19);
        dc.drawText(rightX, bottomY, Graphics.FONT_LARGE, backTaskName, Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    // Get task name for display using cached data
    function getTaskName(taskIndex as Lang.Number) as Lang.String {
        // Use cached task name for efficiency
        var taskName = TaskerUtils.getCachedTaskName(taskIndex);
        
        // Return task name or fallback to dash for unassigned tasks
        if (taskName.length() > 0) {
            return taskName;
        } else {
            return "-"; // Unified symbol for unassigned tasks
        }
    }


}
