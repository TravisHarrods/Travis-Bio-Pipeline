package Travis::Bio::Pipeline::Plugin::Stat;

# Show statistics on sequence objects

use Moose;
use Travis::Utilities::Log;

extends "Travis::Bio::Pipeline::Plugin";

my $log = Travis::Utilities::Log->new();

#===============================================================================
# BUILD
#===============================================================================
sub BUILD
{
  my $self = shift;
  $self->name('Stat');
  $self->description('Stat plugin provides methods to display statitics and '.
   'summaries on sequence objects.');
}

#===============================================================================
# METHODS
#===============================================================================
# Show stats on sequences
sub sequence {
  my $self = shift;
  my $sf   = shift;

  while( $sf->nextSequence() ) {
    print $sf->sequence()->seqId()."\t".$sf->sequence()->getLength()."\n";
  }
}
