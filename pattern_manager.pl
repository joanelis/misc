#!/usr/bin/perl
#pastisware created by joanelis.
use strict;
use warnings;

my @set1=("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
my @set2=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");
my @set3=("0","1","2","3","4","5","6","7","8","9");
my $args = 0;
my $pattern ='';
my $g = 0;
my $i = 0;
my $j = 0;
my $h = 0;
my $patt_len = 450000;
my $curr_len = 0;
my $eip = 0;
my $char1 = '';
my $char2 = '';
my $char3 = '';
my $char4 = '';
my $search_val = '';
my $search_val_pos = 0;

sub on_error {
        print "\nusage : perl pattern_create.pl [ c \<length_of_your_pattern\> | s <EIP> ]\n\n";
        print "c -> create a pattern, 450000 chars max\n";
        print "s -> search for EIP in the pattern\n";
        exit;
}

if ((($#ARGV+1) < 1 ) || (($#ARGV+1) > 3)) {
	&on_error();
}

if (($patt_len !~ m/^[0-9]+$/) || ($patt_len > 450000)) {
	&on_error();
}

if ($patt_len > 450000) {
	&on_error();
}

while ($curr_len < $patt_len){
	if ($g == 26){
		$g = 0;
		$h +=1;
	}
	
	if ($h == 10){
		$h = 0;
		$j +=1;
	}
	
	if ($j == 26){
		$j = 0;
		$i +=1;
	}
	
	if ($i == 26){
		print "the requested pattern is too long";
		exit;
	}
	
	$pattern .= $set1[$i];
	$pattern .= $set2[$j];
	$pattern .= $set3[$h];
	$pattern .= $set2[$g];
	$curr_len += 4;
	$g +=1;
}

if ($ARGV[0] eq 'c') {
	foreach $args (0 .. $#ARGV) {
		$patt_len = $ARGV[1];
	}
	print substr $pattern, 0, $patt_len ;
	exit;
}

elsif ($ARGV[0] eq 's') {
	
	$eip = $ARGV[1];
	if (($eip !~ m/^[0-9|A-F|a-f]{8}$/) && (length($eip) == 8)) {
		print "\nThe address you typed is not valid\n";
		exit;
	}
	
	$char1 = $eip;
	$char1 =~ s/^[0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f]//;
	$char1 = hex($char1);
	$char1 = chr($char1);
	
	print "char 1 = " . $char1 . "\n";
	
	$char2 = $eip;
	$char2 =~ s/^[0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f]//;
	$char2 =~ s/[0-9|A-F|a-f][0-9|A-F|a-f]$//;
	$char2 = hex($char2);
	$char2 = chr($char2);
	
	print "char 2 = " . $char2 . "\n";
	
	$char3 = $eip;
	$char3 =~ s/^[0-9|A-F|a-f][0-9|A-F|a-f]//;
	$char3 =~ s/[0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f]$//;
	$char3 = hex($char3);
	$char3 = chr($char3);
	
	print "char 3 = " . $char3 . "\n";
	
	$char4 = $eip;
	$char4 =~ s/[0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f][0-9|A-F|a-f]$//;
	$char4 = hex($char4);
	$char4 = chr($char4);
	
	print "char 4 = " . $char4 . "\n";
	
	$search_val = $char1;
	$search_val .= $char2;
	$search_val .= $char3;
	$search_val .= $char4;
	
	print "\nsearching \"" . $search_val . "\" in the pattern...\n";
	
	$search_val_pos = index ($pattern, $search_val);
	
	if ($search_val_pos == -1) {
		print "\nimpossible to find this string\n";
		exit;
	}
	
	print "\nposition of \"" . $search_val . "\" in the pattern : " . $search_val_pos . "\n";
}

else {
	&on_error();
}

exit;
