use strict;
use warnings;
package Email::Pipemailer::DieHandler;
# ABSTRACT: do not die embarassingly if you screw up your pipemailer

=head1 SYNOPSIS

  #!/usr/bin/perl
  use Email::Pipemailer::DieHandler -install;
  use strict;
  use warnings;

  # your code goes here

Always put the DieHandler before B<anything> else.  You want there to be
B<absolutely> no condition that will cause a bounce, right?  That includes
failure to compile.

This is also legal:

  use Email::Pipemailer::DieHandler -install => { logger => sub { ... } };

The error will be passed to the sub.

=cut

sub import {
  my ($self, $install, $arg) = @_;
  return unless $install and $install eq '-install';

  $arg ||= {};
  my $logger = $arg->{logger} || sub {};

  $SIG{__DIE__} = sub {
    return if $^S; # don't interfere with evals
    my ($e) = @_;
    defined $^S and eval { $logger->($e); };
    $! = 75;
    die $e;
  };
}

1;
