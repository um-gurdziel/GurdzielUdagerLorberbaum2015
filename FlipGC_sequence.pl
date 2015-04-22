#!/usr/local/bin/perl -w

if (scalar(@ARGV) != 3)
	{print "perl FlipGC_seqeunce.pl sequencefile NumberOfFiles StartingNumber\n";
	print "perl FlipGC_seqeunce.pl chr4.fa 10 1\n";
	exit();
	}

#capture file stub for sequence name
@fileinfo = split (/\//, $ARGV[0]);
@filename = split (/\./, $fileinfo[-1]);
	
#array of filehandles
@filehandles = ();
$i = 1; 	#iterator for the number of files to generate

#open files that will contain the generated flipGC sequences
while ($i <= $ARGV[1])
	{$filenumber = $i + $ARGV[2] -1;
	$flipfilename = $filename[0]. "_" . $filenumber . "." . $filename[1];
	local *FILE;
	open (FILE, ">$flipfilename") || die ("Failed to open $flipfilename\n");
	push (@filehandles, *FILE);
	$i++;
	}

#open sequence file
open (SEQUENCE, $ARGV[0]) || die ("Failed to open $ARGV[0]\n");

#process sequence file and generate flipGC sequences
@randGC = ("C", "G");
@randAT = ("A", "T");
		
while ($line = <SEQUENCE>)
	{#print $line;
	if ($line =~ ">")
		{otherCharacter ($line, \@filehandles);
		#print "$line";
		}
	else 
		{#process each nucleotide in the sequence string- one for each file
		#return character is included and will preserve the same format as the original sequence file
		
		@nucleotide = split ('', $line, length ($line));
		
		foreach $nucl (@nucleotide)
			{if ($nucl =~ /[GgCc]/)
				{
				flipGC (\@randGC, \@filehandles);
				}
			elsif ($nucl =~ /[AaTt]/)
				{
				flipGC (\@randAT, \@filehandles);
				}
			else
				{otherCharacter ($nucl, \@filehandles);
				#print $nucl;	#could be N
				}
			}
		#exit();
		}	
	}
	
close (SEQUENCE);

foreach $item (@filehandles)
	{close ($item);}

#subroutine for generating sequence
sub flipGC
	{$randRef = shift;	
	$filehandleRef = shift;
	@filehandle = @{$filehandleRef};
	$numfiles = scalar (@filehandle);
	
	for ($n = 0; $n < $numfiles; $n++)
		{$fh = $filehandle[$n];
		$x = int (rand(2));
		print $fh "$randRef->[$x]";
		}
	}
	
sub otherCharacter
	{$character = shift;	
	$filehandleRef = shift;
	@filehandle = @{$filehandleRef};
	$numfiles = scalar (@filehandle);
	
	for ($n = 0; $n < $numfiles; $n++)
		{$fh = $filehandle[$n];
		print $fh "$character";
		}
	}
