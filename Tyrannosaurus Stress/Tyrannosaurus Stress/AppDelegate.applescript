--
--  AppDelegate.applescript
--  Tyrannosaurus Stress
--
--  Created by Adam Schrader on 4/23/15.
--  Copyright (c) 2015 Random Nest. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
    
    --Here's the beginning
    --Tyrannosaurus Stress v1.2 | A tool to stress UUTs within the user environment
    --Created by Adam Schrader for Apple, Inc.
    --Last Modified: 2014-06-10 10:36
    global interval, level, stresstime, runtime, windowstatus
    
    on getuutdetails()
        --Get Mac OS X Version
        set osxver to do shell script "sw_vers -productVersion"
        --Get UUT Serial Number
        set serialnum to do shell script "system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'"
        
        --Set Number of CPU Cores for Testing
        set nocores to do shell script "sysctl -n hw.ncpu"
        --Get the Crazy amounts of memory
        set allofthemem to do shell script "sysctl -n hw.memsize"
        --Make it less crazy (convert bytes to gigabytes)
        set mem to allofthemem / 1.073741824E+9
        
        --Throw it all into a record for return
        set uutdetails to {macosxver:osxver, serial:serialnum, cores:nocores, memory:mem}
        
        return uutdetails
    end getuutdetails
    
    on getappdetails()
        --Set POSIX Application path (for Contents folder)
        set resourcelocation to POSIX path of (path to me) & "Contents/Resources/"
        
        --Read Support Files and Parse
        set websitescsv to resourcelocation & "Support/websites.txt"
        set trailerscsv to resourcelocation & "Support/trailers.txt"
        
        --Read/Parse the files to AppleScipt lists
        --External files are used for web-browsing and trailer lists
        set websites to readfile(websitescsv)
        set trailers to readfile(trailerscsv)
        
        --Set 3D Grapher Location and Examples
        set graphlocation to resourcelocation & "Support/3D Examples/"
        set graphs to (list folder graphlocation)
        
        --Throw into a Record to return
        set appdetails to {appname:"Tyrannosaurus Stress", appversion:"1.2.2", resources:resourcelocation, websitelist:websites, trailerlist:trailers, graphlist:graphs}
        
        return appdetails
    end getappdetails
    
    on logdat(logstr)
        --Get the log file location
        set loglocation to (resources of getappdetails()) & "Log/"
        set logfile to (loglocation & (serial of getuutdetails())) & ".log"
        
        --Format a Date String header
        set datestr to short date string of (current date) & " " & time string of (current date)
        --Add the Date Header to the supplied string
        set modlogstr to (datestr & ": " & logstr)
        
        --Write to Log
        do shell script "echo " & quoted form of modlogstr & " >> " & quoted form of logfile
    end logdat
    
    on readlog()
        --Get the log file location
        set loglocation to (resources of getappdetails()) & "Log/"
        set logfile to (loglocation & (serial of getuutdetails())) & ".log"
        
        --Open in Finder
        tell application "Finder"
            open logfile as POSIX file
        end tell
    end readlog
    
    on cleanlog()
        --Get log file location
        set loglocation to (resources of getappdetails()) & "Log/"
        --Delete the files in Terminal so they don't go to the trash
        do shell script "rm -R " & quoted form of loglocation & "*" --Wildcard that bizzz
    end cleanlog
    
    on readfile(filename) --requires csv file in plain text
        open for access filename
        set parsed to (read filename using delimiter {",", ASCII character 10})
        close access filename
        return parsed
    end readfile
    
    on setlevel()
        --Set Title and Message Text for Preamble
        set tehtitle to "Tyrannosaurus Stress" & appversion of getappdetails() & " | Stress Testing"
        set tehtext to "This application will put the UUT under basic stress testing to isolate user specific issues" & return & return & "These tests include:" & return & "3D Graphics Testing (Grapher) | CPU Testing (Terminal yes) | Internet Testing (Safari Webpage Cycle) | Video Testing (1080p Video Loop)" & return & return & "Please select Stress Level:" & return & "Stun | 4 hour Test (normal operation) " & return & "Kill   | 8 hour Test (heavy operation)" & return & return & "We spared no expense."
        
        --Display Preamble and Stress Selection
        set question to display dialog tehtext buttons {"Quit", "Stun", "KILL!"} default button 1 giving up after 60 with icon caution
        set response to button returned of question
        
        --If the response is KILL!, set the test level (lower is more stressfull)
        if response is equal to "KILL!" then
            --Set Level 1 (Most Stressful) - This does not halve any CPU testing or time (8 hrs)
            set level to 1
            --Else Stun (normal testing); Default if no response is provided
            else if response is equal to "Stun" then
            --Set Level 2 (Less Stressful) - Halves all CPU testing per core and time (4 hrs)
            set level to 2
            else
            --Set level to 0; No Stress
            set level to 0
        end if
        
        return level
    end setlevel
    
    on settime()
        --This will be for users to eventually choose the time they desire for stress, but for now, we'll go off the standard 8 hrs
        --Set the Stress Time global variable
        set stresstime to 28800 / level
    end settime
    
    on launchmonitor()
        --Open Activity Monitor for Status
        tell application "Activity Monitor"
            activate
        end tell
    end launchmonitor
    
    on quitmonitor()
        tell application "Activity Monitor"
            quit
        end tell
    end quitmonitor
    
    on launchcputest(nocores)
        --If you really want to kill it, then 'yes'
        if level is equal to 1 then
            --Run RAW CPU Test per Number of Cores (halved)
            repeat nocores / 2 times
                tell application "Terminal"
                    do script "yes > /dev/null"
                end tell
            end repeat
            --Log it!
            logdat("CPU Float Test Started!")
        end if
    end launchcputest
    
    on quitcputest()
        if level is equal to 1 then
            --Be Sure to try and tell yes - NO!
            try
                do shell script "killall yes"
            end try
            
            --Wait a sec
            delay 0.5
            
            tell application "Terminal"
                quit saving no
            end tell
            
            --Log it!
            logdat("CPU Float Test Ended")
        end if
    end quitcputest
    
    on launchvideotest()
        --Pick a Random Trailer (full URL from CSV file)
        set trailers to (trailerlist of getappdetails())
        set trailer to item (random number from 1 to (count of trailers)) of trailers
        
        --Run 1080p Video Loop Test
        try
            tell application "QuickTime Player"
                open URL trailer
                delay 5 --Delay and allow for some buffering before playing
                activate
                set looping of the front document to true
                set muted of the front document to true
            end tell
            
            --Log it!
            logdat("1080p Video Loop Started!")
            on error the error_message number the error_number
            errr(error_number, error_message, "Video Loop Test")
        end try
        
        --Get Graph location (Possibly remove later??)
        set graphlocation to (resources of getappdetails()) & "Support/3D Examples/"
        
        --Run 3D Graphics Tests (Do Last so 3D Models render and animate)
        set graphs to (graphlist of getappdetails())
        try
            tell application "Grapher"
                activate
                repeat with i in graphs
                    set graphtest to (graphlocation & i)
                    open graphtest
                end repeat
            end tell
            
            --Log it!
            logdat("3D Graph Test Started!")
            on error the error_message number the error_number
            errr(error_number, error_message, "3D Graph Test")
        end try
    end launchvideotest
    
    on quitvideotest()
        --Do the Cleanups
        tell application "QuickTime Player"
            quit
        end tell
        
        tell application "Grapher"
            quit saving no
        end tell
        
        --Log it!
        logdat("Video Tests Ended")
    end quitvideotest
    
    on launchwebtest()
        --Prep Webpage cycle test (Open Safari)
        try
            tell application "Safari"
                open location "http://www.apple.com/"
                activate
            end tell
            
            --Log it!
            logdat("Web Test Started!")
            on error the error_message number the error_number
            errr(error_number, error_message, "Web Page Test")
        end try
    end launchwebtest
    
    on cyclewebtest()
        --Run PING Test to check network
        networktest()
        set websites to (websitelist of getappdetails())
        try
            tell application "Safari"
                --Load random page in Safari window
                set the URL of the front document to item (random number from 1 to (count of websites)) of websites
            end tell
            on error the error_message number the error_number
            errr(error_number, error_message, "Web Page Cycle Test")
        end try
    end cyclewebtest
    
    on quitwebtest()
        try --Try to quit Safari nicely
            tell application "Safari"
                quit saving no
            end tell
            on error --If it errors, kill it
            do shell script "killall Safari"
            logdat("Safari had to be killed, forcibly")
        end try
        
        --Log it!
        logdat("Web Test Ended")
    end quitwebtest
    
    on pingtest()
        --Attempt PING to opendns.org
        try
            do shell script "ping -o opendns.org"
            set networkup to true
            on error
            set networkup to false
        end try
        return networkup
    end pingtest
    
    on networktest()
        if pingtest() is true then
            --Update Network Statistics at some point
            else
            logdat("Network Test Failed: Unable to reach opendns.org")
        end if
    end networktest
    
    on windowcontrol(action)
        --Get OS Version
        set osxver to macosxver of getuutdetails()
        try
            if action is true then
                --Set the Status of Windows to TRUE
                set windowstatus to true
                --If pre-Lion, set launch Exposé All Windows
                if osxver is less than 10.7 and osxver is greater than 10.3 then
                    --Ignore if errors occur
                    ignoring application responses
                        --Launch Exposé from Terminal
                        do shell script "/Applications/Utilities/Expose.app/Contents/MacOS/Expose 3"
                    end ignoring
                    else if osxver is less than 10.2 then
                    --Else launch Mission Control
                    tell application "Mission Control"
                        launch
                    end tell
                end if
                --Close Windowing Exposé or Mission Control
                else
                --Set Window Status to False
                set windowstatus to false
                --If pre-Lion, set launch Exposé All Windows
                if osxver is less than 10.7 and osxver is greater than 10.3 then --So hack, very code, much needs improve
                    --Press ESC to exit windowing
                    tell application "System Events" to tell process "Expose"
                    set frontmost to true
                    key code 53
                end tell
                else if osxver is less than 10.2 then --So hack, very code, much needs improve
                --Quit Mission Control
                tell application "Mission Control"
                    quit
                end tell
            end if
        end if
        on error the error_message number the error_number
            errr(error_number, error_message, "Windowing System")
        end try
        --Return Window Status
        return windowstatus
    end windowcontrol
    
    on launchallthestress()
        --Log it!
        logdat("Hold on to your butts... Stress is about to start")
        
        --Launch each test
        launchmonitor()
        launchwebtest()
        --Set Number of Cores
        set coretest to cores of getuutdetails()
        launchcputest(coretest)
        launchvideotest()
        windowcontrol(true)
    end launchallthestress
    
    on stresscheck(runtime)
        --If Stress Runtime eclipses the total test then set variable to stop
        if runtime is greater than stresstime / level then
            set cont to false
            --Otherwise set variable to true
            else
            set cont to true
        end if
        --Return the status
        return cont
    end stresscheck
    
    on getstressdetails()
        --Get the system details for stress log updates
        set load to do shell script "sysctl vm.loadavg"
        --Throw them into a record for return
        set stressdetails to {uutload:load}
        return stressdetails
    end getstressdetails
    
    on quitallthestress()
        --Log it!
        logdat("Cleanup is about to begin...")
        
        --Quit some things...
        quitvideotest()
        quitwebtest()
        quitcputest()
        quitmonitor()
        windowcontrol(false)
    end quitallthestress
    
    on errr(num, mess, func)
        --Set the good error stuff
        set the error_text to (func & " Error: " & num & ": " & mess)
        --If OS Support Notifications, then show those instead of Alerts
        if macosxver of getuutdetails() is greater than 10.9 then
            display notification error_text with title appname of getappdetails() subtitle "It's a UNIX system! I know this!"
            else
            display dialog error_text buttons {"OK"} default button 1 giving up after 5
        end if
        --Log it!
        logdat(error_text as string)
    end errr
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        --Set stressin to false, because it hasn't started
        set giveup to false
        set runtime to 0 --Set Runtime to 0
        set interval to 15 --Default 15 seconds for refresh
        
        --Run Pre-flight checks for interwebs
        repeat while pingtest() is false
            --Display dialog if Interwebs are not up and Pre-flight checks not completed
            set precheck to display dialog "> access main program" & return & "access: PERMISSION DENIED" & return & return & "Ah ah ah! You didn't say the magic word! Ah ah ah! Ah ah ah!" & return & return & "You must be connected to the Interwebs to run the test" with icon caution buttons {"Give Up", "Retry"} default button 2
            --If giving up, quit
            if button returned of precheck is "Give Up" then
                --Set the stop variable
                set giveup to true
                --Exit the loop
                exit repeat
            end if
        end repeat
        
        --If stop word was not said
        if giveup is false then
            --Chose stress level
            setlevel()
            --If level is more than 0, log and stress appropriately
            if level > 0 then
                --Set stress time
                settime()
                
                logdat("Tyrannosaurus Stress is about to start")
                --Get UUT Details to put in log
                set uutdetails to getuutdetails()
                
                logdat("Mac OS X Version: " & macosxver of uutdetails & " | " & "Cores: " & cores of uutdetails & " | " & "Memory: " & memory of uutdetails & "GB")
                logdat("Stress Level: " & level)
                
                --Do all the stresses
                launchallthestress()
                --Otherwise, quit
                else
                quit
            end if
            --Otherwise, quit
            else
            quit
        end if
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        --If stress actually started, then cleanup
        if runtime is greater than 0 then
            
            --Make sure cleanup is performed
            quitallthestress()
            
            --Log it!
            logdat("End of Stress Test")
            
            --Display Confirmation that Stress Test completed
            set question to display dialog "Clever girl... Tyrannosaurus Stress finished doing stuff." buttons {"Quit", "View Log..."} default button 2 with icon note
            set response to button returned of question
            
            --If View Log is desired, open the Log in Finder
            if response is equal to "View Log..." then
                --Read Log
                readlog()
            end if
            
            --Ask confirmation to delete log files
            set question to display dialog "Tyrannosaurus Stress | Would you like to delete log files and quit?" buttons {"Delete Files and Quit"} default button 1 with icon note
            set response to button returned of question
            
            --Regardless of the response to the question, delete the logs
            cleanlog()
            
        end if
        
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    --Idle function which cycles while app is running, used previously for logging and web testing
    on idle
        --Loop Stress Test based on runtime and stresstime Global Variables
        repeat while stresscheck(runtime) is true
            --Cycle webpages
            cyclewebtest()
            
            --Change Windowing to Prevent Burn-in on older displays (default 5 mins)
            if runtime > 0 and (runtime mod 300 is 0) then
                --Flip the bit on windowstatus
                windowcontrol(not windowstatus)
            end if
            
            --Write the hourly log
            if runtime mod 3600 is 0 then
                set logdeats to uutload of getstressdetails()
                logdat("UUT Load: " & logdeats)
            end if
            --Update the global runtime
            set runtime to runtime + interval
            --Return Idle command
            return interval
        end repeat
        
        --Loop test complete, log and quit
        logdat("Looping Tests Complete")
        quit
        
    end idle
	
end script