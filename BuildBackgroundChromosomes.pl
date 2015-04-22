#!/usr/local/bin/perl -w

if (scalar(@ARGV) != 3)
	{print "perl BuildBackgroundChromosomes.pl CoordinateForNativeChromosome BatchCoordinateOfBackgroundSequences NumberofBGchromsomesToGenerate\n";
	exit();
	}

#collect the motifs that occurred in the FlipGC sequences
%BGmotifs = ();
$location = 0;

open (BACKGROUND, $ARGV[1]) || die ("Failed top open $ARGV[1]");
while ($line = <BACKGROUND>)
	{($location, $motif) = split (/\s/, $line);
	if (defined ($BGmotifs{$motif}) )
		{$BGmotifs{$motif} = $BGmotifs{$motif} . ":" . $location;
		}
	else
		{$BGmotifs{$motif} = $location;
		}
	}
close (BACKGROUND);

#compile the number and type of motifs found in the native chromosome
%motifs = ();

open (NATIVE, $ARGV[0]) || die ("Failed top open $ARGV[0]");
while ($line = <NATIVE>)
	{($location, $motif) = split (/\s/, $line);
	if (defined ($motifs{$motif}) )
		{$motifs{$motif} = $motifs{$motif} + 1;
		}
	else
		{$motifs{$motif} = 1;
		}
	}
close (NATIVE);

@fileinfo = split (/\//, $ARGV[0]);
@filename = split (/\./, $fileinfo[-1]);
$outputfile = "$filename[0]_BGchr_" . $ARGV[2] . ".txt";

open (OUTPUT, ">$outputfile") || die ("Failed top open $outputfile");

$i = 0; 
while ($i < $ARGV[2])
	{#generate the background chromosomes with matching kind and number of motifs to native
	foreach $key (keys %motifs)
		{$it = 0;
		$tempstorage = "";
	
		while ($it < $motifs{$key})
			{@coords = split (":", $BGmotifs{$key});
			
			#randomly select matching motif from the background sequences
			$selection = int(rand($#coords+1));
			print OUTPUT "$coords[$selection]\n";

			#remove item from list so it can not be reselected but save for next chromosome to be built
			$tempstorage = $tempstorage . ":" . $coords[$selection];
			
			splice (@coords, $selection, 1);
			$remainder = join (":", @coords);
			$BGmotifs{$key} = $remainder;
			$it++;
			}
		
		$BGmotifs{$key} = $BGmotifs{$key} . $tempstorage;
		}
	$i++;
	}
	
close (OUTPUT);
	

	
