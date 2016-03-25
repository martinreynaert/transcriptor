#!/usr/bin/perl
## Copyright Martin Reynaert 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016
## MRE 2015-07-07
## TransApp system version 0.01

##This Perl wrapper, TransApp-wrapper.pl, is the result of NWO Kiem project Transcription App coordinated by Prof. Dr. Nicoline van der Sijs at Radboud University, Nijmegen, The Netherlands.

##This Perl wrapper is part of the interface between the CLAM web application/service that puts TICCLops and the TransApp system online. 

##This wrapper passes on user parameters as defined in the web application to the main Perl wrapper, T.pl.

use Getopt::Std;

# OPTIONS
getopts('N:I:T:');

$collection = $opt_N;
$interlang = $opt_I;
$targetlang = $opt_T;

$ROOTDIR = $ARGV[0];
$INPUTDIR = $ARGV[1];
$OUTPUTDIR = $ARGV[2];
$TICCLTOOLS = $ARGV[3];
$STATUSFILE = $ARGV[4];
$PROJECT = $ARGV[5];

print STDERR "TEST: COL: $collection IL: $interlang TL: $targetlang ROOT: $ROOTDIR IN: $INPUTDIR OUT: $OUTPUTDIR TOOLS: $TICCLTOOLS STATUS: $STATUSFILE NAME: $PROJECT\n";

print STDERR "ARGUMENTS: $ARGUMENTS\n";

#open (STATUS, ">>$STATUSFILE");

#$pid = open(README, " perl $ROOTDIR/TICCLops.pl $ARGUMENTS |")  or die "Couldn't fork: $!\n";

if ($collection =~ /GEO/){
$pid = open(README, " perl $ROOTDIR/TransApp.pl -a $ROOTDIR -b $TICCLTOOLS -c $INPUTDIR -d $OUTPUTDIR -e $ROOTDIR/JRCnames/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f $ROOTDIR/JRCnames/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i $ROOTDIR/TransApp/GeoNames/cities1000.2.txt -j $ROOTDIR/TransApp/GeoNames/alternateNames.txt -k $PROJECT -l 4 -m 5 -n 100000000000 -o $collection -p 10 -q en -r $interlang -s $targetlang -t $INPUTDIR/input.txt >$OUTPUTDIR/output.txt |")  or die "Couldn't fork: $!\n";
}
elsif ($collection =~ /JRC/){
$pid = open(README, " perl $ROOTDIR/TransApp.pl -a $ROOTDIR -b $TICCLTOOLS -c $INPUTDIR -d $OUTPUTDIR -e $ROOTDIR/JRCnames/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.lc.UNDERSCORE.chars -f $ROOTDIR/JRCnames/JRCnames.LexicalSenses.3cols.UTF8.15.OnlyWithSenseIDs.NamesOnlyOnePerLine.sortu.tsv.cut1.clip500.ld2.charconfus -i $ROOTDIR/JRCnames/jrcnames_uri.nt.clusterFreq.UTF8.langsort.txt -j $ROOTDIR/JRCnames/JRCnames.LexicalSenses.3cols.NameSenseLang.UTF8.txt -k $PROJECT -l 4 -m 5 -n 100000000000 -o $collection -p 10 -q en -r $interlang -s $targetlang -t $INPUTDIR/input.txt >$OUTPUTDIR/output.txt |")  or die "Couldn't fork: $!\n";
}
else {

}

while (<README>) { 

}
close(README) or die "Couldn't close: $!\n";
#close(STATUS);
