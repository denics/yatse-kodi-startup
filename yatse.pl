#!/usr/bin/perl -w
#
# Yatse wakeup for Kodi - UDP wol server
#

use strict;
use warnings;
use POSIX;
use IO::Socket;
use File::Pid;

my $daemonName    = "yatse";
# used for "infinte loop" construct - allows daemon mode to gracefully exit
my $dieNow        = 0;                                     
# number of seconds to wait between "do something" execution after queue is clear
my $sleepMainLoop = 10;                                   
# 1= logging is on / 0= logging is off - use for debug
my $logging       = 1;
# log file path
my $logFilePath   = "/var/log/";                           
my $logFile       = $logFilePath . $daemonName . ".log";
# PID file path
my $pidFilePath   = "/var/run/";
my $pidFile       = $pidFilePath . $daemonName . ".pid";

my($sock, $newmsg, $hishost, $MAXLEN, $PORTNO);

$MAXLEN = 1024;
$PORTNO = 9;

my $YatseWakeUp = "YatseStart-Xbmc";
my $cmd = 'service kodi start';

# daemonize
use POSIX qw(setsid);
chdir '/';
umask 0;
open STDIN,  '/dev/null'   or die "Can't read /dev/null: $!";
open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";
defined( my $pid = fork ) or die "Can't fork: $!";
exit if $pid;

# dissociate this process from the controlling terminal that started it and stop being part
# of whatever process group this process was a part of.
POSIX::setsid() or die "Can't start a new session.";
 
# callback signal handler for signals.
$SIG{INT} = $SIG{TERM} = $SIG{HUP} = \&signalHandler;
$SIG{PIPE} = 'ignore';

# Kodi pid file
my $kodipid	  = File::Pid->new( { file => '/var/run/kodi.pid', } );
# create pid file in /var/run/
my $pidfile = File::Pid->new( { file => $pidFile, } );
$pidfile->write or die "Can't write PID file, /dev/null: $!";
 
# turn on logging
if ($logging) {
    open LOG, ">>$logFile";
	select((select(LOG), $|=1)[0]); # make the log file "hot" - turn off buffering
}

# inform we started correctly
logEntry("Kodi wake up from Yatse");
logEntry("©2015 - Denis Pitzalis");
logEntry("Wait $sleepMainLoop seconds before doing anything");
 
# "infinite" loop where some useful process happens
until ($dieNow) {
	sleep($sleepMainLoop);
	# TODO secure connection and listen only from trusted (subnet or list?) IPs
	$sock = IO::Socket::INET->new(LocalPort => $PORTNO,
	Proto => 'udp') or die "Can't bind: $@";

	logEntry("Waiting for a signal from Yatse remote on port $PORTNO");
    
  while ($sock->recv($newmsg, $MAXLEN)) {
 		if (index($newmsg, $YatseWakeUp) != -1) {
			logEntry("Yatse calling \n");
			if ( my $num = $kodipid->running ) {
				logEntry("Kodi is still running, doing nothing: $num");
			} else {
				logEntry("Yatse starting kodi: $newmsg");
				system($cmd);
			}
		}
		$sock->send("CONFIRMED: $newmsg ");
	}
	die "recv: $!"; 
}
 
# add a line to the log file
sub logEntry {
	my ($logText) = @_;
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
	my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
	if ($logging) {
		print LOG "$dateTime $logText\n";
	}
}
 
# catch signals and end the program if one is caught.
sub signalHandler {
# this will cause the "infinite loop" to exit
	$pidfile->remove;
	logEntry("Yatse listener is closing. Good night!");
	$dieNow = 1; 
}
 
# do this stuff when exit() is called.
END {
	if ($logging) { close LOG }
}
