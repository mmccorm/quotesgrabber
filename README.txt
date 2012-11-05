This is/will be a set of Perl scripts that I use to monitor the stock market.
They're also the very first things I wrote in Perl so they may do things in a kludgy way in many places.

The three symbol scripts get the updated list of actively traded stocks on the AMEX, NYSE, and NASDAQ respectively.

The remaining stockquotesgetter script queries all currently traded stocks for price/volume/etc every time it is called.

Currently I run them all as cron jobs, so that each symbol script gets asks for the latest symbols list just before trading starts,
and the quotesgetter runs every 10 minutes during the trading day.

They start and stop times of trading change over the years and they are not currently automatically updated in any way
you have to hand change them in the cron file.

Ok that's a readme start.
