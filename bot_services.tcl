#
#  nickserv interface for eggdrops
#    bot_services.tcl
#


# setup the globals variables
set nick_pass  "";
set nick_email "";
set nick_vhost "";


# setup the triggers
set reg_trigger "!register";
set ident_trigger "!ident";
set vhost_trigger "!newvhost";


# build the bindings
bind msg mn $reg_trigger register_nick;
bind msg mn $ident_trigger identify_nick;
bind msg mn $vhost_trigger request_vhost;

##
## define and build the procs
##

#  send the registration info
proc register_nick { nick user handle texti } {
	puthelp "PRIVMSG NickServ REGISTER '$::nick_pass $::nick_email'";
}

#  send the identify info
proc identify_nick { nick user handle texti } {
    putserv "PRIVMSG NickServ IDENTIFY $::nick_pass";
}

#  request a new vhost
proc request_vhost { nick user handle texti } {
    putserv "PRIVMSG HostServ REQUEST $::nick_vhost";
}



putlog "\002eggdrop services tool ONLINE\002";
