#!/usr/bin/perl
#Analyze a bin and print useful informations for exploitation
#based on readelf output because everybody's going to cry if you ask them to install a perl lib
use strict;
use warnings;
use English;

my ($file, $info, $line, $temp, $X, $W, $X_list, $W_list, $entry_point);
$file = $info = $line = $temp = $X = $W = $X_list = $W_list = $entry_point = "";
my $objdump_cmd = "objdump -d";
my (@section, @objdump);
@section = @objdump = ();
my $id = `id -u`;
my $i = 0;

sub on_error {
        print "\nusage : aelf.pl <bin_to_analyze>\n";
	print "Note : you need to be root\n\n";
        exit;
}

#Check if supplied arg is an elf bin and if we are root
if (!defined($ARGV[0])) {
	&on_error;
}
if ((-x $ARGV[0]) && ($id == 0)){
	$file = $ARGV[0];
}
else {
	&on_error;
}
$info = `file $file`;
if($info !~ m/ELF/){
	&on_error;
}

#Check mitigation techniques, thx to trapkit.de
print "Mitigation techniques : \n";
#Check for NX
$info = `readelf -W -l $file`;
if($info =~ m/GNU_STACK/){
	print "   > NX :      \033[31mYes\033[m\n";
}
else{
	print "   > NX :      \033[32mNo\033[m\n";
}
#Check for RELRO
if($info =~ m/GNU_RELRO/){
	$info = `readelf -W -d $file`;
	if($info =~ m/BIND_NOW/){
		print "   > RELRO :   \033[31mFull\033[m\n";
	}
	else{
		print "   > RELRO :   \033[33mPartial\033[m\n";
	}
}
else{
	print "   > RELRO :   \033[32mNo\033[m\n";
}
#Check for rpath
$info = `readelf -W -d $file`;
if($info =~ m/rpath/){
        print "   > Rpath :  \033[31mYes\033[m\n";
}
else{
        print "   > Rpath :   \033[32mNo\033[m\n";
}
#check for runpath
if($info =~ m/runpath/){
	print "   > Runpath : \033[31mYes\033[m\n";
}
else{
	print "   > Runpath : \033[32mNo\033[m\n";
}
#Check for canary
$info = `readelf -W -s $file`;
if($info =~ m/__stack_chk_fail/){
	print "   > Canary :  \033[31mYes\033[m\n";
}
else{
	print "   > Canary :  \033[32mNo\033[m\n";
}
#Check for PIE
$info = `readelf -W -h $file`;
if($info =~ m/Type:[[:space:]]*EXEC/){
	print "   > PIE :     \033[32mNo\033[m\n";
}
if($info =~ m/Type:[[:space:]]*DYN/){
	if($info =~ m/(DEBUG)/){
		print "   > PIE :     \031[33mYes\033[m\n";
	}
	else{
		print "   > PIE :     \033[33mDSO\033[m\n";
	}
}
#find entry point, doesn't work if locale != english
foreach (split(/\n/, $info)){
	if($_ =~ m/Entry point/){
		$entry_point = $_;
		$entry_point =~ s/  //g;
		$entry_point =~ s/Entry point address:/   >/;
	}
}
print "\nEntry point : \n" . $entry_point . "\n";
#list writable and executable sections (color if W+X)
@section = `readelf -W -S $file`;
foreach $line (@section){
	if($line =~ m/X/){
		$temp = $line;
		$temp =~ s/^.*\./\./;
		$temp =~ s/([a-z])\ .*$/$1/;
		if($temp !~ m/W.*A.*X.*M.*S.*/){
			#for a later use
			$objdump_cmd .= " --section=" . $temp;
			$temp =~ s/^/   > /;
			$X .= $temp;
		}
	}
        if($line =~ m/W/){
		$temp = $line;
                $temp =~ s/^.*\./\./;
                $temp =~ s/([a-z])\ .*$/$1/;
                if($temp !~ m/W.*A.*X.*M.*S.*/){
			$temp =~ s/^/   > /;
                        $W .= $temp;
                }
        }
	if($X eq $W){
		$X =~ s/(\..*)/\033\[32m$1\033\[m/;
	}
	$X_list .= $X;
	$W_list .= $W;
	$X = "";
	$W = "";
}
print "\nExecutable sections : \n";
print $X_list;
print "\nWritable sections : \n";
print $W_list;
exit;