# SAM irc bot
# -- This version is a drastically modified version of "radio IRC TCL script by SharkMachine"
# -- 
# --  This script is designed to be used with disfigure's custom SAM listener PAL scripts.
#       This eggdrop script shoudl have come packaged with the PAL scripts needed.
#       This script also requires the "mysqltcl 3.01" package as well as the "http" module for eggdrops.

package require mysqltcl 3.01;
package require http;

# Edit these to match the info for you SAM broadcaster mysql login
#set SAMserver nexus.tech-noid.net;
set SAMserver 65.23.154.172;
set SAMuser streaminfo;
set SAMpass <password>;
set SAMdb samdb;
set SAMport "3306";

# The station website
set station_www www.tech-noid.net;

# ad timer variable.  set this to the time (in minutes) for the channel advertisments
set adtime 10;

# the admin channel for using special functions.   ie skip  :)
set adminchan "#tech-noid.admin #tech-noid";

# the channel or channels (separated with space) where the script will works
set dachan "#tech-noid #music #dnbarena #production #36hz";

# the channels that we will auto announce the station information
set annouce_chan "#tech-noid";

# and edit these, if you want.
set listen_trigger "!links";
set listeners_trigger "!count";
set playing_trigger "!np";
set next_trigger "!next";
set prev_trigger "!prev";
set help_trigger "!help";
set peak_trigger "!peak";
set triggers_trigger "!triggers";
set skip_trigger "!skip";
set liveshow_np "!id";
set alarm_trigger "!!!";

#set rating_trigger "!rate";
#set comment_trigger "!comment";
#set comments_trigger "!comments";

#  lets build the binds needed for the triggers to work in IRC
#
#   these are the public binds (ie in channels we have the script activated)
bind pub - $listen_trigger links;
bind pub - $listeners_trigger listeners;
bind pub - $playing_trigger playing;
bind pub - $next_trigger next;
bind pub - $prev_trigger prev;
bind pub - $help_trigger help;
bind pub - $peak_trigger peak;
bind pub - $triggers_trigger triggers;
bind pub RA|RA $skip_trigger skip_stream;
bind pub - $liveshow_np whatisthis;
bind pub - $alarm_trigger alarm;

#bind pub - $rating_trigger rate_song;
#bind pub - $comment_trigger comment;
#bind pub - $comments_trigger comments;
#
#   these are the binds used to make the script usefull via a provate message to the bot  
bind msg - $listen_trigger listen_msg;
bind msg - $listeners_trigger listeners_msg;
bind msg - $playing_trigger playing_msg;
bind msg - $next_trigger next_msg;
bind msg - $prev_trigger prev_msg;
bind msg - $peak_trigger peak_msg;
bind msg - $help_trigger help_msg;
bind msg - $triggers_trigger triggers_msg;
#bind msg - $comment_trigger comment_msg;
#bind msg - $comments_trigger comments_msg;
#
#   tie the private message binds to the public message processes.
proc listen_msg { nick user handle text } { links $nick $user $handle $nick $text; }
proc listeners_msg { nick user handle text } { listeners $nick $user $handle $nick $text; }
proc playing_msg { nick user handle text } { playing $nick $user $handle $nick $text; }
proc next_msg { nick user handle text } { next $nick $user $handle $nick $text; }
proc prev_msg { nick user handle text } { prev $nick $user $handle $nick $text; }
proc peak_msg { nick user handle text } { peak $nick $user $handle $nick $text; }
proc help_msg { nick user handle text } { help $nick $user $handle $nick $text; }
proc triggers_msg { nick user handle text } { triggers $nick $user $handle $nick $text; }
#proc comment_msg { nick user handle text } { comment $nick $user $handle $nick $text; }
#proc comments_msg { nick user handle text } { comments $nick $user $handle $nick $text; }

#   =============================================================================================================
#      WARNING - CODE BELOW -- BE CAREFULL IF EDITING
#   =============================================================================================================


proc whatisthis { nick user handle channel text } {
        set continue 0;
        for {set x 0} {$x < [llength $::dachan]} {incr x} {
                if { [lindex $::dachan $x] == $channel } { set continue 1; }
        }
        for {set x 0} {$x < [llength $::adminchan]} {incr x} {
                if { [lindex $::adminchan $x] == $channel } { set continue 1; }
        }
        if { $nick == $channel } { set continue 1; }
        if { $continue == 1 } {
        puthelp "PRIVMSG $channel : \002 HEY DJ!!!  TRACK INFO PLEASE!! \002";
        }
        putlog "\002ID triggered in $channel by $nick\002";
}

proc alarm { nick user handle channel text } {
        set continue 0;
        for {set x 0} {$x < [llength $::dachan]} {incr x} {
                if { [lindex $::dachan $x] == $channel } { set continue 1; }
        }
        for {set x 0} {$x < [llength $::adminchan]} {incr x} {
                if { [lindex $::adminchan $x] == $channel } { set continue 1; }
        }
        if { $nick == $channel } { set continue 1; }
        if { $continue == 1 } {
        putquick "PRIVMSG $channel :\001ACTION runs around in a panic!!!!..\001";
        puthelp "PRIVMSG $channel : \002OMG OMG OMG OMG !!! !!! !!! \002";
        }
        putlog "\002ALARM triggered in $channel by $nick\002";
}


#  this is the triggers function
#  --  !triggers  - this returns the public triggers; defined above
proc triggers { nick user handle channel texti } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set reqs_on "";
		puthelp "PRIVMSG $nick : Tech-Noid Systems Triggers: $::listeners_trigger  $::playing_trigger $::next_trigger $::prev_trigger  $::peak_trigger  $::help_trigger  $::listen_trigger  $::rating_trigger  $::comment_trigger  $::comments_trigger";
	}
	putlog "\002TRIGGERS triggered in $channel by $nick\002";
}

#  WE SHOULD CHANGE THIS TO A DB/PAL THING
#  this is the listen links function
#  --  !links  - returns the relays used to tune in to the station; 
proc links { nick user handle channel texti } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		puthelp "PRIVMSG $nick :\002Tech-Noid Systems Radio Links:\002";
		puthelp "PRIVMSG $nick : ";
                puthelp "PRIVMSG $nick :\002 128k MP3\002 \0035-\003 http://radio.tech-noid.net:9000/listen.pls";
                puthelp "PRIVMSG $nick :\002 128k MP3\002 \0035-\003 http://listen.36hz.net:9000/tech-noid";
		puthelp "PRIVMSG $nick :\002 128k MP3 - WebClient\002 \0035-\003 http://listen.36hz.net";
                puthelp "PRIVMSG $nick :\002 64k  MP3\002 \0035-\003 http://radio.tech-noid.net:8000/listen.pls";
                puthelp "PRIVMSG $nick :\002 32k  AAC\002 \0035-\003 http://radio.tech-noid.net:10000/listen.pls";
                puthelp "PRIVMSG $nick : ";
	}
	putlog "\002LINKS in $channel by $nick\002";
}

#  this is the help function
#  --  !help  - returns the help message; modify as needed
proc help { nick user handle channel texti } {
	global botnick;
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		puthelp "PRIVMSG $nick :\002Tech-Noid Systems Radio Channel Bot Commands:\002";
		puthelp "PRIVMSG $nick : ";
		puthelp "PRIVMSG $nick :\002 $::listeners_trigger\002 - this will display the listener count";
		puthelp "PRIVMSG $nick :\002 $::playing_trigger\002 - this will display what is playing on the station";
		puthelp "PRIVMSG $nick :\002 $::next_trigger\002 - this will display the next six songs that will play on the station";
		puthelp "PRIVMSG $nick :\002 $::prev_trigger\002 - this will display the previous six songs that played on the station";
		puthelp "PRIVMSG $nick :\002 $::peak_trigger\002 - this will display the listener count peak and song that was playing when it happened";
		puthelp "PRIVMSG $nick :\002 $::listen_trigger\002 - this will display the different station listen links";
		puthelp "PRIVMSG $nick :\002 $::rating_trigger # <comment>\002 - rate the song playing;  # = 0-10    <comment> = a comment about the song (optional)";
		puthelp "PRIVMSG $nick :\002 $::comment_trigger <comment>\002 - adds a comment to the song playing";
		puthelp "PRIVMSG $nick :\002 $::comments_trigger\002 - displays the comments for the song playing";
	}
	putlog "\002HELP triggered in $channel by $nick\002";
}

#  this is the skip song function
#  --  !skip  - skips the track playing; requires 'skip_track.pal' to function
proc skip_stream { nick user handle channel text } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {	
		# open the connection to the SAM event and fire the skip trigger
		set skipURL "http://master.tech-noid.net:1221/event/skip_track";
		::http::config -useragent "Mozilla/5.0; Shoutinfo"
		set http_req [::http::geturl $skipURL -timeout 2000]
		set data [::http::data $http_req]	
	}
	puthelp "PRIVMSG $channel : \002 Stream skipped by $nick - 2 to 5 second delay..plz wait\002";	
	putlog "\002SKIP triggered in $channel by $nick\002";
}

#  this is the peak listener count function
#  --  !peak  - returns the peak listener count; calculated using 'listener_counts.pal' in SAM
proc peak { nick user handle channel texti } {
	global botnick;
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb;
		set sqlResult [mysqlsel $h "SELECT listeners, artist, title, date_played FROM listener_peak ORDER BY listeners DESC LIMIT 0,1" -flatlist]
		set peakcount [lindex $sqlResult 0];
		set trackplaying1 [lindex $sqlResult 1];
		set trackplaying2 [lindex $sqlResult 2];
		set trackplaying3 [lindex $sqlResult 3];
		putlog "$peakcount $trackplaying1 $trackplaying2 $trackplaying3";
		puthelp "PRIVMSG $channel : \002Listener Peak:\002  $peakcount listeners :: $trackplaying3 GMT-8 :: $trackplaying1 - $trackplaying2 ";
	}
	mysqlclose $h;
	putlog "\002PEAK triggered in $channel by $nick\002";
}

#  this is the now playing function
#  --  !np  - returns what is playing now on the station
proc playing { nick user handle channel text } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb; 
		mysqlsel $h "SELECT artist, title, duration, album, filename FROM historylist ORDER BY date_played DESC LIMIT 0, 1";
		mysqlmap $h {artist title duration album filename} {
			if {$album == ""} {
				set output "\002Now playing ::\002  $artist - $title";
			} else {
				set output "\002Now playing ::\002  $artist - $title  on  $album";
			}
		}
	}
	puthelp "PRIVMSG $channel : $output";
	mysqlclose $h;
	putlog "\002NOW PLAYING triggered in $channel by $nick\002";
}

#  this is the up-coming tracks function
#  --  !next  - returns the next 5 tracks that should play on the station
proc next { nick user handle channel text } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb;
		mysqlsel $h "SELECT songlist.ID, songlist.artist, songlist.title, songlist.duration, songlist.album FROM queuelist, songlist WHERE (queuelist.songID = songlist.ID)  AND (songlist.songtype='S' OR songlist.songtype='J') ORDER BY queuelist.sortID ASC LIMIT 0, 6";
		set i 0;
		mysqlmap $h {songid artist title duration album} {
			if { $i == 0 } { puthelp "PRIVMSG $nick :\002Coming Up Next:\002"; 
					    puthelp "PRIVMSG $nick :-=- $artist - $title";}
			if { $i != 0 } { puthelp "PRIVMSG $nick :-=- $artist - $title"; }
			incr i;
		}
	}
	mysqlclose $h;	
	putlog "\002NEXT TRACKS triggered in $channel by $nick\002";
}

#  this is the previous tracks function
#  --  !prev  - returns the last 5 tracks that played on the stream; returned by privmsg
proc prev { nick user handle channel text } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb;
		mysqlsel $h "SELECT artist, title, duration, album, filename FROM historylist ORDER BY date_played DESC LIMIT 1, 6"
		set i 0;
		mysqlmap $h {artist title duration album filename} {
			if { $i == 0 } { 
				puthelp "PRIVMSG $nick :\002Previous Songs Played:\002"; 
				puthelp "PRIVMSG $nick :-=- $artist - $title";
			}
			if { $i != 0 } { puthelp "PRIVMSG $nick :-=- $artist - $title"; }
			incr i;
		}
	}
	mysqlclose $h;
	putlog "\002PREVIOUS TRACKS triggered in $channel by $nick\002";
}

#  this is the  function
#  --  !count  - returns the current lister count
proc listeners { nick user handle channel text } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb;
		mysqlsel $h "SELECT viewers FROM relay_counts ORDER BY id DESC LIMIT 0,1";
		mysqlmap $h {listeners} { 
			puthelp "PRIVMSG $channel : \002Current Listener Count:\002  $listeners "; 
		}
	}
	mysqlclose $h;
	putlog "\002LISTENER COUNT triggered in $channel by $nick\002";
}
 
## BETA VERSION -- THIS IS NOT FUNCTIONAL AS OF YET!!!
#  this is the rating function for the station
#  --  !rate # <comment>  - adds or changes rating on song; will add comment if present
#proc rate_song { nick user handle channel texti } {
#	set continue 0;
#	for {set x 0} {$x < [llength $::dachan]} {incr x} {
#		if { [lindex $::dachan $x] == $channel } { set continue 1; }
#	}
#	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
#		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
#	}
#	if { $nick == $channel } { set continue 1; }
#	if { $continue == 1 } {	
#		set newrate 0;
#		set rate_count 0;
#		set nowplaying "";
#		set artistsplaying "";
#		set titleplaying "";
#		set userrate [lindex $texti 0];
#		set usercomment [lrange $texti 1 end];
#		switch $userrate {
#			"" { set canwerate DISPLAY; }
#			"0" { set canwerate YES; }
#			"1" { set canwerate YES; }
#			"2" { set canwerate YES; }
#			"3" { set canwerate YES; }
#			"4" { set canwerate YES; }
#			"5" { set canwerate YES; }
#			"6" { set canwerate YES; }
#			"7" { set canwerate YES; }
#			"8" { set canwerate YES; }
#			"9" { set canwerate YES; }
#			"10" { set canwerate YES; }
#			"default" { set canwerate NO; }
#		}
#		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
#		mysqluse $h $::SAMdb;
#		mysqlsel $h "SELECT artist, title, duration, album, songID FROM historylist ORDER BY date_played DESC LIMIT 0, 1";
#		mysqlmap $h {artist title duration album songID} {			
#			set nowplaying $songID;
#			set artistplaying $artist;
#			set titleplaying $title;
#		} 
#		if { $canwerate == YES } {
#			set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
#			mysqluse $h $::SAMdb;
#			set fixednick \"$user\";
#			set sqlResult [mysqlsel $h "SELECT whorated FROM userratings WHERE (songID=$nowplaying AND whorated=$fixednick)" -flatlist];
#			#putlog "[lindex $sqlResult 0] $nick $user $fixednick";
#			if { [lindex $sqlResult 0] == $user } {
#				putlog "rating is in DB";
#				if { $usercomment == "" } {
#					putlog "no comment";
#					mysqlexec $h "UPDATE userratings SET userrate=$userrate WHERE (songID=$nowplaying AND whorated=$fixednick)";
#					#puthelp "PRIVMSG $channel :\002Rating Saved";
#				} else {
#					putlog "comments";
#					mysqlexec $h "UPDATE userratings SET userrate=$userrate WHERE (songID=$nowplaying AND whorated=$fixednick)";
#					mysqlexec $h "INSERT INTO songcomments (songID, whorated, comment, nickname) VALUES ('$nowplaying', '$user', '$usercomment', '$nick')";
#					#puthelp "PRIVMSG $channel :\002Rating Saved with Comment";
#				}
#			} else {
#				putlog "rating NOT in the DB";
#				if { $usercomment == "" } {
#					putlog "no comment";
#					mysqlexec $h "INSERT INTO userratings (artist, title, songID, whorated, userrate) VALUES ('$artistplaying', '$titleplaying', '$nowplaying', '$user', '$userrate')";
#					#puthelp "PRIVMSG $channel :\002Rating Saved";
#				} else {
#					putlog "comments";
#					mysqlexec $h "INSERT INTO userratings (artist, title, songID, whorated, userrate) VALUES ('$artistplaying', '$titleplaying', '$nowplaying', '$user', '$userrate')";
#					mysqlexec $h "INSERT INTO songcomments (songID, whorated, comment, nickname) VALUES ('$nowplaying', '$user', '$usercomment', '$nick')";
#					#puthelp "PRIVMSG $channel :\002Rating Saved with Comment";
#				}			
#			}
#			
#			
#			mysqlsel $h "SELECT songID, userrate FROM userratings WHERE songID = $nowplaying";
#			mysqlmap $h {songID, rate_userrate} {					
#				set newrate [expr $newrate + $rate_userrate];
#				incr rate_count;
#			}			
#			set newrate [expr $newrate / $rate_count];
#
#			set checksong [mysqlsel $h "SELECT songID FROM songratings WHERE songID = $nowplaying" -flatlist];
#			if { [lindex $checksong 0] == "" } { 
#				putlog "new song to be added to the ratings list";
#				mysqlexec $h "INSERT INTO songratings (songID, rating, timesrated) VALUES ('$nowplaying', '0', '0')";
#			}
#			
#			mysqlexec $h "UPDATE songratings SET rating=$newrate, timesrated=$rate_count WHERE songID=$nowplaying";			 
#			
#			if { [lindex $sqlResult 0] == $user } {
#				putlog "updated the rating you had";
#				putlog "[lindex $sqlResult 0]"
#				puthelp "NOTICE $nick :\002Your rating has been changed to $userrate\002";
#				puthelp "NOTICE $nick :\002'$artistplaying - $titleplaying'  Rating: $newrate/10\002";
#				if { $usercomment != "" } { puthelp "NOTICE $nick :\002'$usercomment' added to comments\002"; }
#			} else {
#				putlog "[lindex $sqlResult 0]"
#				putlog "new rating for you";
#				puthelp "NOTICE $nick :\002You rated $userrate\002";
#				puthelp "NOTICE $nick :\002'$artistplaying - $titleplaying'  Rating: $newrate/10\002";
#				if { $usercomment != "" } { puthelp "NOTICE $nick :\002'$usercomment' added to comments\002"; } 
#			}
#			putlog "\002SONG RATE triggered in $channel by $nick\002";
#			putlog "\002RATING = $userrate    NEW RATING = $newrate\002";
#		}
#		
#		
#		if { $canwerate == "NO"} { 
#			puthelp "PRIVMSG $channel :\002Please rate 0-10 only!\002"; 
#			putlog "\002SONG RATE triggered in $channel by $nick\002";
#		}		
#		if { $canwerate == "DISPLAY" } {
#			mysqlsel $h "SELECT songID, rating, timesrated FROM songratings WHERE songID=$nowplaying";
#			set sqlResults [mysqlsel $h "SELECT rating, timesrated FROM songratings WHERE songratings.songID = $nowplaying" -flatlist];
#			set songrate [lindex $sqlResults 0];
#			set timesrated [lindex $sqlResults 1];
#			puthelp "PRIVMSG $channel :\002'$artistplaying - $titleplaying'  Rating: $songrate/10 (times rated: $timesrated)";
#			putlog "\002SONG RATE triggered in $channel by $nick\002";
#		} 
#	}
#	mysqlclose $h; 
#}

#  this is the comment function for the station
#  --  !comment <comment>  - adds a comment for the song to the database 'songcomments'
proc comment { nick user handle channel texti } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb;
		set sqlResult [mysqlsel $h "SELECT artist, title, duration, album, songID FROM historylist ORDER BY date_played DESC LIMIT 0, 1" -flatlist];
		set artist [lindex $sqlResult 0];
		set title [lindex $sqlResult 1];
		set nowplaying [lindex $sqlResult 4];
		set usercomment [lrange $texti 0 end];
		putlog "$artist  $title  $nowplaying  $usercomment";
		if { $usercomment == "" } {
			putlog "yes";
			puthelp "PRIVMSG $channel :\002 To add a comment try !comment <comment>\002";
		} else {
			putlog "no";
			mysqlexec $h "INSERT INTO songcomments (songID, whorated, comment, nickname) VALUES ('$nowplaying', '$user', '$usercomment', '$nick')";
			puthelp "PRIVMSG $nick :\002 You have added a comment to $artist - $title";
			puthelp "PRIVMSG $nick :\002 Added: '$usercomment'";
			puthelp "PRIVMSG $channel :\002Comment Saved";
		}
	}
	mysqlclose $h;
	putlog "\002ADD COMMENT triggered in $channel by $nick\002";
}

#  this is the comment display function for the station
#  --  !comments - displays the comments associated with the song; requires database 'songcomments'
proc comments { nick user handle channel texti } {
	set continue 0;
	for {set x 0} {$x < [llength $::dachan]} {incr x} { 
		if { [lindex $::dachan $x] == $channel } { set continue 1; }
	}
	for {set x 0} {$x < [llength $::adminchan]} {incr x} {
		if { [lindex $::adminchan $x] == $channel } { set continue 1; }
	}
	if { $nick == $channel } { set continue 1; }
	if { $continue == 1 } {
		set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
		mysqluse $h $::SAMdb;		
		set sqlResult [mysqlsel $h "SELECT artist, title, duration, album, songID FROM historylist ORDER BY date_played DESC LIMIT 0, 1" -flatlist];
		set artist [lindex $sqlResult 0];
		set title [lindex $sqlResult 1];
		set nowplaying [lindex $sqlResult 4];
		putlog "$artist  $title  $nowplaying";
		set sqlResult2 [mysqlsel $h "SELECT id FROM songcomments WHERE (songID=$nowplaying) ORDER BY id LIMIT 0, 1" -flatlist];
		set commentcheck [lindex $sqlResult2 0];
		if { $commentcheck == "" } { 
			puthelp "PRIVMSG $channel :\002 No Comments to Display -  use !comment to add one\002";
		} else {
			mysqlsel $h "SELECT id, comment, nickname FROM songcomments WHERE songID=$nowplaying ORDER BY id";
			set i 0;
			mysqlmap $h {id comment nickname} {
				if { $i == 0 } { 
					puthelp "PRIVMSG $channel :\002Comments for $artist - $title"; 
					puthelp "PRIVMSG $channel :[expr $i + 1]. $comment - by $nickname";
				}
				if { $i != 0 } { puthelp "PRIVMSG $channel :[expr $i + 1]. $comment - by $nickname"; }
				incr i;
			}
		}		 
	}
	mysqlclose $h;
	putlog "\002COMMENT DISPLAY triggered in $channel by $nick\002";
}
		
#   =============================================================================================================
#       ANNOUNCEMENT SCRIPT HERE  --  THIS IS THE WHAT TELLS EVERYONE WHATS PLAYING
#   =============================================================================================================

#  fire up our timer and process the go() process
if {![info exists ald]} {
	set ald 1 
	timer $adtime go
}
#  this is the process that starts on script load.
#   we fire our timer at the end of the announcement to keep things going
proc go {} {
	global botnick; 
	global adtime;
	global station_www;
	set h [mysqlconnect -h  $::SAMserver -u $::SAMuser -password $::SAMpass -port $::SAMport];
	mysqluse $h $::SAMdb;
	set sqlResult [mysqlsel $h "SELECT artist, title, duration, album, songID FROM historylist ORDER BY date_played DESC LIMIT 0, 1" -flatlist];
	set sqlResult2 [mysqlsel $h "SELECT viewers FROM relay_counts ORDER BY id DESC LIMIT 0,1" -flatlist];
	set artist [lindex $sqlResult 0];
	set title [lindex $sqlResult 1];
	set album [lindex $sqlResult 3];
	set listeners [lindex $sqlResult2 0];
	set nowplaying [lindex $sqlResult 4];
	#set sqlResult3 [mysqlsel $h "SELECT rating, timesrated FROM songratings WHERE songratings.songID = $nowplaying" -flatlist];
	#set songrate [lindex $sqlResult3 0];
	#set ratecount [lindex $sqlResult3 1];
	#if {[lindex $sqlResult3] == "" } {
	#	set output "\002Now playing ::\002 $artist - $title \002:: Rating:\002 $songrate/10 (times rated: $ratecount) \002:: Listeners Tuned:\002 $listeners \002:: $station_www\002";
	#} else {
	#	set output "\002Now playing ::\002 $artist - $title  on  $album \002:: Rating:\002 $songrate/10 (times rated: $ratecount) \002:: Listeners Tuned:\002 $listeners \002:: $station_www\002";
	#}

	set output "\002Now playing ::\002 $artist - $title \002:: \002:: Listeners Tuned:\002 $listeners \002:: $station_www\002";

	for {set x 0} {$x < [llength $::dachan]} {incr x} {
		puthelp "PRIVMSG [lindex $::annouce_chan $x] : $output";
	}
	mysqlclose $h;
	putlog "\002Announcements sent\002";
		
	# time to start over again
	timer $adtime go
}


#  display in the eggdrop log and console that we are online
#
putlog "\002SAM Broadcaster Eggdrop Bot v1.1 by disfigure (www.tech-noid.net)  ONLINE\002";
