#!/usr/local/bin/perl -w

if (scalar(@ARGV) != 2)
	{print "perl IdentifyMotifs.pl sequencefile libraryfile\n";
	print "perl IdentifyMotifs.pl chr4.fa Motif.txt\n";
	exit();
	}
	
#create a hash of motifs for comparison to sequences
%motifs = ();
open (LIBRARY, $ARGV[1]) || die ("Failed to open $ARGV[1]\n");

$line = <LIBRARY>;
($motif, $value) = split (/\s/, $line);
$motiflength = length ($motif);
$motifs {$motif} = $value;

while ($line = <LIBRARY>)
	{($motif, $value) = split (/\s/, $line);
	if (length ($motif) != $motiflength)
		{print "Library file contains motifs of different lengths\n";
		exit();
		}
	else 
		{$motifs {uc($motif)} = $value;
		}
	}
close (LIBRARY);
	
#create output file
@fileinfo = split (/\//, $ARGV[1]);
@filename = split (/\./, $fileinfo[-1]);
$outputfile = $filename[0];
@fileinfo = split (/\//, $ARGV[0]);
@filename = split (/\./, $fileinfo[-1]);
$outputfile = "Coords_" . $outputfile . "_" . $filename[0] . ".txt";

open (OUTPUT, ">$outputfile") || die ("Failed to open $outputfile\n");

#scan sequence file for location of motifs
open (SEQUENCE, $ARGV[0]) || die ("Failed to open $ARGV[0]\n");

$remainder = "";
$line = <SEQUENCE>;
if ($line !~ />/)	#skip fasta identification line
	{$remainder = $line;}

$location = 1;		
while ($line = <SEQUENCE>)
	{$sequence = $remainder . $line;
	$sequence =~ s/\s//g;
	$seqlength = length ($sequence);
	$i = 0;
	while ($i < $seqlength - $motiflength)
		{$test = substr ($sequence, $i, $motiflength);
		
		if (defined ($motifs {uc($test)}) )
			{#output location and motif type
			print OUTPUT "$location\t$test\t$motifs{uc($test)}\n";
			#exit();
			}
		$i++;
		$location++;
		}
	$location++;
	$remainder = substr ($sequence, length($sequence)-($motiflength-1));
	}
	
close (SEQUENCE);
close (OUTPUT);

