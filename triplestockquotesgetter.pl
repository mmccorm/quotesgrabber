#!perl -w
# triplestockquotesgetter.pl, previously stockquotesgetter.pl
# Mark McCormick mark.mccormick.01@gmail.com 
# LAST MODIFIED 112508
# change 112508: load symbols for NASDAQ, NYSE AND AMEX from automatic daily updated symbol lists, 
# concatenate those lists, and use to get all quotes.
# previously just used a static NASDAQ list.
# LAST PREVIOUS MODIFICATION 12-07-07
# CHANGE 12-17-07: finance.yahoo.com changed to download.finance.yahoo.com
# later: change &f=sl1d1t1c1ohgv&e=csv to &f=sl1v and change daynextdayhasher
# or what the fuck ever collates these to accomodate the change- it will make the files smaller.

use strict;
use IO::Socket;

my $localtime = localtime;
$localtime =~ s/((\s)|:)//g;

# The stock symbols to check are read in successively from three files, NASDAQstocksymbols.txt,
# NYSEstocksymbols.txt, and AMEXstocksymbols.txt, which are themselves updated daily by NASDAQsymbolegetter.pl,
# AMEXsymbolgetter.pl, etc. as a cron job before the start of trading.

open NASDAQSYMBOLS, "</home/mark/stockquotes/NASDAQstocksymbols.txt" or die "Cannot open filehandle NASDAQSYMBOLS (/home/mark/stockquotes/NASDAQstocksymbols.txt): $!\n";
my $NASDAQsymbols = <NASDAQSYMBOLS>;
my @NASDAQsymbols = split / /, $NASDAQsymbols;
close NASDAQSYMBOLS or die "Cannot close filehandle NASDAQSYMBOLS (/home/mark/stockquotes/NASDAQstocksymbols.txt): $!\n";

open AMEXSYMBOLS, "</home/mark/stockquotes/AMEXstocksymbols.txt" or die "Cannot open filehandle AMEXSYMBOLS (/home/mark/stockquotes/AMEXstocksymbols.txt): $!\n";
my $AMEXsymbols = <AMEXSYMBOLS>;
my @AMEXsymbols = split / /, $AMEXsymbols;
close AMEXSYMBOLS or die "Cannot close filehandle AMEXSYMBOLS (/home/mark/stockquotes/AMEXstocksymbols.txt): $!\n";

open NYSESYMBOLS, "</home/mark/stockquotes/NYSEstocksymbols.txt" or die "Cannot open filehandle NYSESYMBOLS (/home/mark/stockquotes/NYSEstocksymbols.txt): $!\n";
my $NYSEsymbols = <NYSESYMBOLS>;
my @NYSEsymbols = split / /, $NYSEsymbols;
close NYSESYMBOLS or die "Cannot close filehandle NYSESYMBOLS (/home/mark/stockquotes/NYSEstocksymbols.txt): $!\n";

#open SYMBOLS, "<condensedsymbols.txt" or die "Cannot open filehandle SYMBOLS (condensedsymbols.txt): $!\n";
#my $symbols = <SYMBOLS>;
#my @symbols = split / /, $symbols;
my @symbols = (@NASDAQsymbols, @AMEXsymbols, @NYSEsymbols);
my $symcounter  = 0;
my $remainderyes = 0;
# TEST CONFIGURATION!!!! my $symbols = "ARDI,OIIM,CTAC,FLWS,FCCY,FIFG,SRCE,SRCEO";		
#close SYMBOLS or die "Cannot close filehandle SYMBOLS (condensedsymbols.txt): $!\n";

unless ( @symbols%200 == 0 ) {$remainderyes = 1;}
my $timesthrough = (int(@symbols/200)) + $remainderyes;

my @splitsymbols = ();

open OUTPUT, ">/home/mark/stockquotes/quotes$localtime.csv" or die "Couldn't open filehandle OUTPUT (/home/mark/stockquotes/quotes$localtime.csv): $!\n";

for (1..$timesthrough) {
	my $sentsymbols = ();
	my @working200 = ();
	for (1..200) {
		my $shifted = shift @symbols;
# DIAGNOSTIC print "$shifted";
		if ($shifted) {
		   push @working200, $shifted;
		   }
    	}
	$sentsymbols = join ",", @working200;
# DIAGNOSTIC print "sentsymbols is $sentsymbols";
# DIAGNOSTIC print " enter to continue";
# DIAGNOSTIC chomp (my $waiting = <STDIN>);
	
	my $server  = 'download.finance.yahoo.com';
	my $port    = '80';
	my $request = "/d/quotes.csv?s=$sentsymbols&f=sl1d1t1c1ohgv&e=csv";
# DIAGNOSTIC print "$request";
    
	my $remote = new IO::Socket::INET (Proto=>'tcp',
                                       PeerAddr=>$server,
                                       PeerPort=>$port,
                                       Reuse=>1 ) or die $!;
	$remote->autoflush(1);
	print $remote "GET $request HTTP/1.0\n\n";
    
	while (<$remote>) {
	  	  chop;
	  	  my $line = $_;
# DIAGNOSTIC print "$line\n";
	  	  print OUTPUT "$line";
      	  }
		  close $remote;
	}
close OUTPUT or die "Couldn't close filehandle OUTPUT (/home/mark/stockquotes/quotes$localtime.csv): $!\n";
# WORKING.
