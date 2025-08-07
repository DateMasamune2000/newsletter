#!/usr/bin/perl

use utf8;
use strict;
use warnings;

use open qw(:std :encoding(UTF-8));
use LWP::Simple;
use Env qw(HOME);
use File::stat;
use XML::RSS;
use Term::ANSIColor;

my $cachepath = "$HOME/.cache/newsletter";
my %myfeeds = (
	'smashingcss.xml'
		=> 'https://www.smashingmagazine.com/category/css/index.xml',
	'smashingjs.xml'
		=> 'https://www.smashingmagazine.com/category/javascript/index.xml',
	'smashingperf.xml'
		=> 'https://www.smashingmagazine.com/category/performance/index.xml',
	'smashingtools.xml'
		=> 'https://www.smashingmagazine.com/category/tools/index.xml',
	'smashingtools.xml'
		=> 'https://www.smashingmagazine.com/category/guides/index.xml',
);

while (my ($name, $link) = each(%myfeeds)) {
	my $feedname = $link;
	my $cachefn = "$cachepath/$name";

	my $st = stat($cachefn);

	if (not $st) {
		print STDERR "Fetching from URL...\n";

		my $content = get($feedname);
		die "ERROR: failed to access feed $feedname" unless defined $content;

		open my $TEMPFILE, ">", $cachefn;
		print $TEMPFILE $content;
		close $TEMPFILE;

		print "Content fetched succesfully.\n";
	} else {
		print STDERR "Found feed file $cachefn.\n";
	}

	my $data = "";

	open my $newsfile, "<", $cachefn;
	while (my $line = <$newsfile>) {
		$data .= $line;
	}
	close($newsfile);

	my $rss = XML::RSS->new();
	$rss->parse($data);

	my $channel = $rss->channel;
	my $image = $rss->image;

	print color('bold yellow') . $channel->{title} . color('reset') . "\n";

	foreach my $item (@{$rss->{items}}) {
		print color('bold') . $$item{title} . color('reset')
		. "\n" . color('blue') . $$item{link} . "\n\n" . color('reset');
	}
}
