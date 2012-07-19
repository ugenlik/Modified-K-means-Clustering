#!usr/bin/perl -w

use strict;

package Point;
#constructor for point
sub new
{
	my $self = {}; shift;
	@{ $self->{DIMENSIONS} } = @_;
	bless($self);
	return $self;
}

# get/set method for dimensions
sub dimensions
{
	my $self = shift;
	if (@_) { @{ $self->{DIMENSIONS} } = @_ }
        return @{ $self->{DIMENSIONS} };
}

#calculate distance to other point
sub distanceTo
{
	my $self = shift;
	my $other = shift;
	my @distDim = ();
	my $len = $#{$self->{DIMENSIONS}}+1;
	for (my $i=0; $i<$len; $i++)
	{	push  @distDim, (($self->{DIMENSIONS}->[$i] - $other->{DIMENSIONS}->[$i])**2);	}
	my $sum = 0;
	$sum += $_ for @distDim;
	my $dist = sqrt($sum);
	return $dist;
}
# equals method for point
sub equals
{
	my $self = shift;
	my $other = shift;
	if ($#{$self->{DIMENSIONS}} != $#{$other->{DIMENSIONS}})
	{return 0;}
	my $bool = 1;
	for (my $i=0; $i<$#{$self->{DIMENSIONS}}+1; $i++)
	{
		if (${$self->{DIMENSIONS}}[$i] != ${$other->{DIMENSIONS}}[$i])
		{ 	$bool = 0; last;	}
	}
	return $bool;
}

1;

package Cluster;

#constructor for the cluster
sub new
{	
	my $self = {}; shift;
	@{ $self->{POINTS} } = @_;
	$self->{CENTROID} = shift;
	bless($self);
	return $self;
}

# get/set method for points
sub points
{
	my $self = shift;
	if (@_) { @{ $self->{POINTS} } = @_ }
        return @{ $self->{POINTS} };
}
# get/set method for centroid
sub centroid
{
	my $self = shift;
	if (@_) {$self->{CENTROID} = shift;}
	return $self->{CENTROID};
}
#find the centroid of the cluster
sub findCentroid
{
	my $self = shift;
	if ($#{$self->{POINTS}}==-1) { return 0; }
	my @dim = ();	
	for (my $i=0; $i<$#{$self->{POINTS}->[0]->{DIMENSIONS}}+1; $i++)
	{
		my $sum=0;
		for (my $j=0; $j<$#{$self->{POINTS}}+1; $j++)
		{
			$sum += $self->{POINTS}->[$j]->{DIMENSIONS}->[$i];			
		}
		push @dim, $sum/($#{$self->{POINTS}->[0]->{DIMENSIONS}}+1);
	}
	$self->{CENTROID} = new Point(@dim);
	return $self->{CENTROID};	
}
#find radius of the cluster
sub findRadius
{
	my $self = shift;
	my @toSum = ();
	for my $i (@{$self->{POINTS}})
	{
		push @toSum, sqrt($i->distanceTo($self->{CENTROID})**2)
	}
	my $sum = 0;
	for my $x (@toSum)
	{ $sum += $x; }
	my $radius = $sum / ($#{$self->{POINTS}}+1);
	return $radius;	
}
# equals method for the cluster
sub equals
{	
	my $self = shift;
	my $other = shift;
	if ($#{$self->{POINTS}} != $#{$other->{POINTS}})
	{ return 0; }
	my $bool = 1;
	for (my $i=0; $i<$#{$self->{POINTS}}+1; $i++)
	{
		if (! ($self->{POINTS}->[$i]->equals($other->{POINTS}->[$i])) )
		{ $bool = 0; last; }
	}
	return $bool;
}
1;

sub kMeans
{
	my $allPoints = shift;
	for (my $i=3; $i<10; $i++)
	{		
		my @randomNums = ();
		for (my $j=0; $j<$i; $j++)
		{
			my $ran = int rand( $#$allPoints );
			while (grep (/$ran/, @randomNums))
			{ 
				$ran = int rand( $#$allPoints );
				if ($#randomNums+1 >= $#$allPoints) { last;}
			}
			push @randomNums, $ran;
		}
		my @clusters = ();
		for (my $x=0; $x<$#randomNums+1; $x++)
		{
			push @clusters, new Cluster((), $allPoints->[$x]);
		}
		my @oldClusters = ();
		my $bool = 1;
		while()
		{
			@oldClusters = ();
			for (my $x=0; $x<$#clusters+1; $x++)
			{ push @oldClusters, $clusters[$x]; }
			my @distances = ();
			for (my $i=0; $i<$#$allPoints+1; $i++)
			{				
				for (my $j=0; $j<$#clusters+1; $j++)
				{ push @distances, $allPoints->[$i]->distanceTo($clusters[$j]->{CENTROID}); }
				my @min = sort {$a <=> $b} @distances;
				my $mindex = 0;
				for my $d (@distances) {if ($min[0]==$d){last;} else {$mindex++;}}
				push @{$clusters[$mindex]->{POINTS}}, $allPoints->[$i];
			}
			$bool = 1;
			for (my $i=0; $i<$#clusters+1; $i++)
			{
				if ($clusters[$i]->equals($oldClusters[$i])) {$bool = 0; last;}
			}
			if (!$bool) { last;}
			
		}
		for (my $i=0; $i<$#clusters+1; $i++)
		{
			$clusters[$i]->{CENTROID} = $clusters[$i]->findCentroid;
		}
		my $sumRad = 0;
		for (my $i=0; $i<$#clusters+1; $i++)
		{
			$sumRad += $clusters[$i]->findRadius;
		}
		my $radAVG = $sumRad / $#clusters+1;
		print "$i, $radAVG \n";
	}
}

open FL, "<../res/synthetic_control.data";
my @data = ();
while (my $line = <FL>)
{
	my @dim = ();
	while ($line =~ /(\S+)/g)
		{push @dim, $1;}
	push @data, (new Point(@dim));
}

&kMeans(\@data);
close FL;
