#line 1
package LWP::Online;

#line 122

use 5.005;
use strict;
use Carp 'croak';
use LWP::Simple qw{ get $ua };

use vars qw{$VERSION @ISA @EXPORT_OK};
BEGIN {
	$VERSION = '1.07';

	# We are an Exporter
	require Exporter;
	@ISA       = qw{ Exporter };
	@EXPORT_OK = qw{ online offline };

	# Set the useragent timeout
	$ua->timeout(30);
}

# Set up configuration data
use vars qw{%SUPPORTED @RELIABLE_HTTP};
BEGIN {
	# What transports do we support
	%SUPPORTED = map { $_ => 1 } qw{ http };

	# (Relatively) reliable websites
	@RELIABLE_HTTP = (
		# These are some initial trivial checks.
		# The regex are case-sensitive to at least
		# deal with the "couldn't get site.com case".
		'http://google.com/' => sub { /About Google/      },
		'http://yahoo.com/'  => sub { /Yahoo!/            },
		'http://amazon.com/' => sub { /Amazon/ and /Cart/ },
		'http://cnn.com/'    => sub { /CNN/               },
	);
}

sub import {
	my $class = shift;

	# Handle the :skip_all special case
	my @functions = grep { $_ ne ':skip_all' } @_;
	if ( @functions != @_ ) {
		require Test::More;
		unless ( online() ) {
			Test::More->import( skip_all => 'Test requires a working internet connection' );
		}
	}

	# Hand the rest of the params off to Exporter
	return $class->export_to_level( 1, $class, @functions );
}





#####################################################################
# Exportable Functions

#line 215

sub online {
	# Shortcut the default to plain http_online test
	return http_online() unless @_;

	while ( @_ ) {
		# Get the transport to test
		my $transport = shift;
		unless ( $transport and $SUPPORTED{$transport} ) {
			Carp::croak("Invalid or unsupported transport");
		}

		# Hand off to the transport function
		if ( $transport eq 'http' ) {
			http_online() or return '';
		} else {
			Carp::croak("Invalid or unsupported transport");
		}
	}

	# All required transports available
	return 1;
}

#line 249

sub offline {
	! online(@_);
}





#####################################################################
# Transport Functions

sub http_online {
	# Check the reliable websites list.
	# If networking is offline, an error/paysite page might still
	# give us a page that matches a page check, while any one or
	# two of the reliable websites might be offline for some
	# unknown reason (DDOS, earthquake, chinese firewall, etc)
	# So we want 2 or more sites to pass checks to make the
	# judgement call that we are online.
	my $good     = 0;
	my $bad      = 0;
	my @reliable = @RELIABLE_HTTP;
	while ( @reliable ) {
		# Check the current good/bad state and consider
		# making the online/offline judgement call.
		return 1  if $good > 1;
		return '' if $bad  > 2;

		# Try the next reliable site
		my $site  = shift @reliable;
		my $check = shift @reliable;

		# Try to fetch the site
		my $content;
		SCOPE: {
			local $@;
			$content = eval { get($site) };
			if ( $@ ) {
				# An exception is a simple failure
				$bad++;
				next;
			}
		}
		unless ( defined $content ) {
			# get() returns undef on failure
			$bad++;
			next;
		}

		# We got _something_.
		# Check if it looks like what we want
		SCOPE: {
			local $_ = $content;
			if ( $check->() ) {
				$good++;
			} else {
				$bad++;
			}
		}
	}

	# We've run out of sites to check... erm... uh...
	# We should probably fail conservatively and say not online.
	return '';
}

1;

#line 372
