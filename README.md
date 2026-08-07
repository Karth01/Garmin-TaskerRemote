# TaskerRemote
A glance/app designed to add smartwatch functionality to a garmin watch via Buttons and Menu screen.

# Description
It does this by allowing you to create custom 'messages' that are sent as notifications to your paired phone. These notifications can be acted upon to do tasks by certain apps on your phone, even the phone's native software. For example, Samsung phones can act on custom notifications natively (via Modes and Routines) and make your phone do jobs you would not usually be able to do from your watch. Examples include, but are not limited to - Emergency phone recording, taking photos, launching a phone assistant or AI for more tasks, better Spotify or music controls, launching apps, sound modes, audiobook... you get the idea.
The main app this is built for is Tasker and Autonotification on android. These do take a bit of time to know but they are powerhouses in phone utility. Again, other notification-driven apps can work just as well.
Upon downloading the Glance/App, make sure it is added to your Glance carousel (I have it as the first glance, so a single press down from the watch face gives quick access).

# Design
TaskerRemote has two main views, configurable via the Connect IQ app after downloading and syncing the watch.
i) Menu View - A list of up to 10 tasks you can assign in a scrollable menu.
- Use Up/Down to navigate and Select to trigger a task.
- If no task is assigned it won't be populated (so you don't scroll through empty tasks).
- The Back button is special - see below.

ii) Button View - This works as a Quick select 'pad' where you can assign tasks to the four hardware buttons on your watch- Up, Down, Select, and Back.
- Pressing the button triggers the assigned task.
- Unassigned buttons display a “–” and are inactive.
- The Back button has a few jobs. It can function as a Task if it has one assigned to it in the Button view; it is responsible for cycling between Menu and Buttons view; and it is responsible for exiting the glance entirely.
- If the Triple exit toggle in SETTINGS is off, then a single press of the Back button will cycle between button view and menu view. A double press will exit the app. A task will be fired if assigned to the Back Button.
- If the toggle is on, then a single press will trigger the task, a double press will cycle between button and menu view, and a triple press will exit the app. There is a short delay in firing the assigned task to allow for this. (Means you can allocate a Button task without immediately shifting views).

# Settings
- Configure the Tasks via the Connect IQ app in 'Settings'. Here, you can also customise it further as follows-
- Switch to Buttons on Select- On Selecting a Menu item, the view will cycle to Buttons View. (This is actually how I use it on Tasker, where the Menu list is actually a Global 'Mode' for me, and then I use the Buttons view as a pad for tasks within that mode. I've pasted one of my older Tasker Projects below as a guide).
- Disable Button Access - Forget the Buttons, just use the Menu List view.
- Launch Buttons Directly - Launch directly into the Buttons view, bypassing Menu View.
- Triple Exit toggle - as above.

# Updates
2. Alternate Tasker Project that replaces Autonotification with native Tasker functions below - combine it with the original project for max effect.
https://taskernet.com/shares/?user=AS35m8kzb0b6gpY9bStc9vqfEb2xmSCrCFe9Q7vuxosbPRpCifzT2k67Ngf%2Bu%2FrxZyiu&id=Profile%3ATASKER_REMOTE_TEMPLATE
Details here
https://www.reddit.com/r/tasker/comments/1u4fjtp/java_code_replacement_for_autonotification_cancel/
- Added toggle for vibration in settings

# Notes & Bugs
- Pre-existing Tasker profiles are widely available on the Garmin store and Tasker forums.
- Known bug: On the Instinct 3 series, launching a custom glance during an activity may stall a custom datafield. Stopping and restarting the activity resolves this issue. Bug report submitted to Garmin.

# Credits / Disclaimers
Built using code from Tasker Trigger by Chelsea Winstone – full credit and thank you for the foundation.
I am not affiliated with Tasker or AutoNotification. All credit belongs to current developer Joao - thank you.
Thanks to Flocsy for help with bug testing.
This is a hobby - I'm not a developer. TaskerRemote is a personal project, tested on my watch. Bugs may exist and support may be limited. If you find TaskerRemote useful, a review is appreciated.
