# NYSEsymbolgetter.pl
# 112508 last modified 052611
# Mark McCormick mark.mccormick.01@gmail.com
# stockquotesgetter.pl runs every ten minutes throughout the trading day as a cron job and retrieves all nasdaq data.
# It used a static symbols list but now NYSEsymbolgetter.pl will
# query the NYSE live list of symbols at
# http://www.nasdaq.com//asp/symbols.asp?exchange=N&start=0
# just before the start of trading every day and make a new reference file for stockquotesgetter to use.

# modifications 052611 because nasdaq changed their shit:
# NASDAQ IS AT http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download
# NYSE IS AT http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download
# AMEX IS AT http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download

# OLD- DEPRECATED
# AMEX IS AT http://www.nasdaq.com//asp/symbols.asp?exchange=1&start=0
# NASDAQ IS AT http://www.nasdaq.com//asp/symbols.asp?exchange=Q&start=0

use strict;
use IO::Socket;
my @symbols;
my $output = "/home/mark/stockquotes/NYSEstocksymbols.txt";

open OUTPUT, ">$output" or die "Cannot open filehandle OUTPUT ($output): $!\n";

my $server  = 'www.nasdaq.com';
my $port    = '80';
my $request = "/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download";

my $remote = new IO::Socket::INET (Proto=>'tcp',
                                       PeerAddr=>$server,
                                       PeerPort=>$port,
                                       Reuse=>1 ) or die $!;
$remote->autoflush(1);
print $remote "GET $request HTTP/1.0\n\n";

while (<$remote>) {

@symbols = <$remote>;

}
close $remote;

foreach my $symbols (@symbols) {
	my $SYMB;
	my @bitsy = split /,/, $symbols;
	my $symbinquotes = $bitsy[0];
	if ($symbinquotes =~ /"([A-Z]{3,5})"/) {
		$SYMB = $1;
	print OUTPUT "$SYMB"." ";
	}
}

close OUTPUT or die "Couldn't close filehandle OUTPUT ($output): $!\n";

# end for now - working as of 052611
