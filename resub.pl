#!/usr/bin/perl

my $para  = $ARGV[0];
my $suff  = $ARGV[1];
my $check = defined($ARGV[2]);

if (!defined($suff)) {$suff="";}

if ($suff eq "check") {$check = true; $suff ="";}

# Example commands
# DPM:    sbatch -a1-20 jobsim_kronos.sh DPM10GeV 1000 DPM         10.0 saveall
# EvtGen: sbatch -a1-20 jobsim_kronos.sh D0Kpi    1000 D0toKpi.dec 10.0 saveall

# print some usage information
if (!defined($para))
{
    print "\nChecks the jobs output (<prefix>_<num>_<suff>.root existing and reasonable in size) and resubmits all failed ones (KRONOS version).\n\n";
    print "USAGE:\n";
    print 'resub.pl "<cmd>" [check]'."\n";
    print "  <cmd>   : The complete sbatch command line in quotes (job script name must be 'job...sh'), the -a parameter the first.\n";
    print "            The 'sbatch -a' at the beginning can optionally be skipped.\n";
    print "            If given a file name 'xxx.jobs' (w/o quotes) instead, the above is done for every command listed in the file.\n";
    print "  <suff>  : Suffix of the filenames; filepattern looked for is <prefix>_<num>_<suff>.root\n";
    print "  [check] : Optional parameter 'check', which just prints out what would be resubmitted\n\n";
    exit(0);
}

my @commands;

# we have a file containing a list of sbatch commands
if ( $para =~ m/\.jobs$/ )
{
    open (in,"<$para");
    @commands= <in>;
    close in;
}
# we only have one sbatch command directly given as parameter
else
{
    push(@commands, $para);
}

my $linecnt=0;
my $totresub=0;
my @resubs;

# for each entry in the commands array
foreach my $cmd (@commands)
{
    # cut away the CR and NL
    chomp $cmd;
	
	if ( $cmd =~ m/^\s*$/) {next;}
    
	# if commented line (first char = '#'), skip
    if ( $cmd =~ m/^#/) {next;}
    
    print "\n\n** LINE $linecnt: ".$cmd."\n";
	$linecnt+=1;
	
    $cmd =~ m/(\d+)-(\d+)(.+)(job.*\.sh)\s+(\w+)\s+(.*)/;

    my $min     = $1;
    my $max     = $2;
    my $parms   = $3;
    my $script  = $4;
    my $pref    = $5;
    my $rest    = $6;
    
	if ($suff eq "")
	{
    	$suff    = "pid";
    	if ($script =~ /jobfsim/) {$suff = "fsim";}   # do we have fast sim output
    	if ($script =~ /jobquickfa/) {$suff = "ana";} # do we have ana output from quickana tool
    }
    print "Checking for files \"data/$pref"."_<run>_$suff.root\" for runs $min - $max (cmd opt: \"-a$min-$max $parms $script $pref $rest\")\n\n";
    
    my @broken=(), @nexist=(), @small=();

    # find run numbers of non-existing and too small file
    for (my $i=$min; $i<=$max; $i++)
    {
		my $fname = "data/".$pref."_".$i."_$suff.root";

		if (!-e $fname) 
		{
	    	push(@broken,$i);
	    	push(@nexist, $i);
		}
		else
		{
	    	my $filesize = -s $fname;
	    	if ($filesize<10000)
	    	{
			push(@broken,$i);
			push(@small,$i);
	    	}
		}
    } 
	
	$totresub += scalar @broken;

    # print out numbers of failed jobs
	my $nnexist = scalar @nexist;
	my $nsmall  = scalar @small;
	
	if ($nnexist+$nsmall==0) 
	{
		print "--> All ok!";
	}
	else
	{
    	print "Not existing : ";
    	foreach my $run (@nexist) {print "$run ";}
    	print "\nSmall file   : ";
    	foreach my $run (@small) {print "$run ";}
    }
	print "\n\n";
    
	if ($nnexist+$nsmall>0)
	{
    	if ($check) {print "Would ";}
    	print "Re-submit : \n";
		
    	foreach my $nums (@broken)
    	{
			# print out the submit command
			my $recmd = "sbatch -a$nums\-$nums$parms$script $pref $rest";
			print "$recmd\n";

			push @resubs, $recmd;

			# if not in check mode, re-submit the jobs 
			if (!$check) {system($recmd);}
    	}
	}
}
print "\n**** Re-submit summary:\n\n";

foreach my $c (@resubs) {print "$c\n";}
print "\n\n";

if ($check) {print "****  Total number of jobs to be re-submitted: $totresub  ****";}
else {print "****  Re-submitted $totresub jobs  ****";}
print "\n\n";
