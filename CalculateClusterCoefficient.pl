#!/usr/local/bin/perl -w

if (scalar(@ARGV) != 4)
	{print "perl CalculateClusterCoefficient.pl CoordFile S_Batch_BGchr_#.txt ClusterSize MaximumClusterLength\n";
	print "perl CalculateClusterCoefficient.pl CoordFile S_Batch_BGchr_#.txt 3 1000\n";
	exit();
	}

#capture information from coordinate filename
@fileinfo = split (/\//, $ARGV[0]);
@filename = split (/\./, $fileinfo[-1]);
@fileinfo = split ("_", $filename[0]);
$chromosome = $fileinfo[2];

$clustersize = $ARGV[2];
$maxclusterlength = $ARGV[3];

#create output file
$outputfile = "Cluster_" . $clustersize . "_". $fileinfo[1] . "_" . $chromosome . ".txt";
open (OUTPUT, ">$outputfile") || die ("Failed to open $outputfile\n");

#capture information from sorted batch background file
@fileinfo = split (/\//, $ARGV[1]);
@filename = split (/\./, $fileinfo[-1]);
@fileinfo = split ("_", $filename[0]);
$numberBGchr = $fileinfo[-1];

open (BG, $ARGV[1]) || die ("Failed to open $ARGV[1]\n");
$BGfileposition = tell(BG);

open (COORDS, $ARGV[0]) || die ("Failed to open $ARGV[0]\n");
$coordfileposition = tell(COORDS);
while ($line = <COORDS>)
	{$coordfileposition = tell(COORDS);
	$i = 0;
	while ($i < $clustersize)
		{push (@data, $line);
		$i++;
		#check for end of line
		if (eof(COORDS) == 1 && $i < $clustersize)
			{close (COORDS);
			close (BG);
			close (OUTPUT);
			exit();
			}
		$line = <COORDS>;
		}
	
	#collect the starting motif position and end motif position
	@startinfo = split (/\s/, $data[0]);
	@endinfo = split (/\s/, $data[-1]);
	$motiflen = length ($startinfo[1]);
	$start = $startinfo[0];
	$end = $endinfo[0] + $motiflen-1;
	
	#check that cluster is within size limit
	$clusterlength = $end - $start;
	if ($clusterlength <= $maxclusterlength)
		{
		#locate the same coordinate space in the background sequence file
		seek (BG, $BGfileposition, 0);
		$BGline = <BG>;
		$BGline =~ s/\s//g;
		
		while ($BGline < $start)
			{#iterate forward
			$BGline = <BG>;
			$BGline =~ s/\s//g;
			}
	
		$BGfileposition = tell (BG);
	
		#found location start location in file
		$BGmotifcount = 0;
		#continue count until outside of cluster 
		while ($BGline <= $end)
			{#iterate forward
		
			#control for end of file
			if (eof(BG) == 1)
				{$BGline = $end +1;
				}
			else 
				{$BGline = <BG>;
				$BGline =~ s/\s//g;
				$BGmotifcount++;
				}
			}
	
		#calculate average sites in background
		if ($BGmotifcount == 0)
			{$BGmotifcount++;
			}
		$average = $BGmotifcount / $numberBGchr;
	
		#calculate cluster coefficient
		$CC = sprintf ("%3.2f", $clustersize / $average);
	
		#calculate average predicted affinity
		$total = 0;
		foreach $item (@data)
			{@info = split (/\s/, $item);
			$total = $total + $info[2];
			}
		$averagePA = sprintf ("%3.2f", $total / $clustersize);
		
		#output the results for the cluster
		foreach $item (@data)
			{@info = split (/\s/, $item);
			$endmotif = $info[0] + $motiflen -1;
			print OUTPUT "$chromosome\t$info[0]\t$endmotif\t$info[1]\t$info[2]\t$start\t$end\t$averagePA\t$CC\n";
			}
		}	
	@data = ();
	#return to the file location of second motif in the cluster and resume processing
	seek (COORDS, $coordfileposition, 0);
	}

close (COORDS);
close (BG);
close (OUTPUT);


	
