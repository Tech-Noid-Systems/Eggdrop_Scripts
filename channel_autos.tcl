## channel_autos.tcl
##  - automatical voice or op all users who join a irc channel.
##  
##  bastardized version of allvoice.tcl
##
##  created 8/8/2006


# What channels should we work on?
# avchan is channel to auto-voice users in
# aochan is channel to auto-op users in
# annchan is channel to send help/message to users who join
#  - note: "" is for all channels

set avchan "#techno-dnb";
set aochan "#nadda";
set annchan "#techno-dnb";


# build our bindings
bind join - * avjoin;
bind join - * aojoin;
bind join - * announcement;


## Begin the code


## auto voice on join section
proc avjoin {nick uhost hand chan} {
	global avchan botnick;
	if {$nick == $botnick} {return 0};
	if {$avchan == "" && [botisop $chan]} {
		pushmode $chan +v $nick;
	return 0
	}
	set chan [string tolower $chan];
	foreach i [string tolower $avchan] {
		if {$i == $chan && [botisop $chan]} {
			pushmode $chan +v $nick;
			return 0;
		} 
	}
	putlog "\002 Auto-Voice given to $nick on $channel";
}

## auto op on join section
proc aojoin {nick uhost hand chan} {
	global aochan botnick;
	if {$nick == $botnick} {return 0};
	if {$aochan == "" && [botisop $chan]} {
		pushmode $chan +o $nick;
		return 0;
	}
	set chan [string tolower $chan];
	foreach i [string tolower $aochan] {
		if {$i == $chan && [botisop $chan]} {
			pushmode $chan +o $nick;
			return 0;
		}
	}
	putlog "\002 Auto-Ops given to $nick on $channel";
}

proc announcement {nick user handle channel} {
	global annchan;
	
	set chan [string tolower $channel];
	foreach i [string tolower $annchan] {
		if {$i == $chan } {
			putserv "NOTICE $nick : \002Welcome to the techno-dnb.com chatroom!!\002";
			putserv "NOTICE $nick : Please do not abuse the bots or users of the channel.  Trolling and/or Flaming will not be tollerated.  Do NOT post links during a live show.  No Colors, No Flooding, No Intentional Retardation. Violating these rules will result in a kick or a temporary ban.  Ban evasion is grounds for permenant removal from the channel.";
			putserv "NOTICE $nick : Please issue \002!help\002 in the channel for more information.  You will recieve a private message (PM) from me with detailed information on what I can do.";	 		
		}
	}
	putlog "\002 Channel Announcement given to $nick on $channel";
}

putlog "\002Channel Tools ver. 1.1  by  disfigure  ONLINE\002";