#!/usr/bin/perl -w
#asm to opcode converter, linux x86 only

use strict;
use warnings;
use English;

my $skel = "section .data\n\nsection .text\n\nglobal _start\n_start:\n";
my $asm_file = 'file.asm';
my $o_file = 'file.o';
my $elf_file = 'file';
my $input_file = "";
my $out = 'shellcode';
my $line = "";

sub on_exit{
        print "\nusage : $0 <file with asm>\n";
        exit;
}

if(!defined($ARGV[0])){
	&on_exit;
}

if(-e $ARGV[0]){
	$input_file = $ARGV[0];
	open INPUT, "<", $input_file or die $!;
}
else{
	print "$ARGV[0] does not exist\n";
	exit;
}

#copy the skel to a temp file in ./
open ASM, ">", $asm_file or die $!;
print ASM $skel;

#add code to the copy of the skel
while (<INPUT>){
        print ASM $_;
}
close(INPUT);

#the dirtiest part
`nasm -g -f elf -o $o_file $asm_file`;
`ld -o $elf_file $o_file`;
`objdump -d $elf_file | sed 's/^[^\ ].*//g;/^\$/d' | cut -b11- | cut -b-18 > $out`;
`rm $asm_file; rm $o_file; rm $elf_file`;

#write the result
open OUT, "<", $out or die $!;
while(<OUT>){
	$line = $_;
	$line =~ s/\r|\n/\ /;
	$line =~ s/\ //g;
	$line =~ s/(..)/$1\ /g;
	print $line;
}
print "\n";
close(OUT);
exit;
