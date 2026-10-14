import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

(:glance)
class TaskerRemoteGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    // onUpdate() is called to update the view
    function onUpdate(dc) as Void {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var centerY = dc.getHeight() / 2;
        dc.drawText(0, centerY, Graphics.FONT_GLANCE, "TaskerRemote", 
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

(:glance)
class TaskerRemoteGlanceDelegate extends WatchUi.GlanceViewDelegate {
    
    function initialize() {
        GlanceViewDelegate.initialize();
    }

    // Simple approach: just return false to launch the main app
    function onSelect() as Lang.Boolean {
        return false;  // Launch main app
    }
    
}