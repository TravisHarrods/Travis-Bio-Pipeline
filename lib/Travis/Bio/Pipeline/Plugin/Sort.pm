package Travis::Bio::Pipeline::Plugin::Sort;
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
   $self->name('Sort');
   $self->description('Sort plugin provides a method to sort features '.
    'inside the different sequence objects.');
}

#===============================================================================
# METHODS
#===============================================================================
sub features {
   my $self = shift;
   my $sf   = shift;

   foreach my $kv ( $sf->listSequenceIndex() ) {
      my $seq_id = $kv->[0];
      my $index  = $kv->[1];
      $log->info('Sorting features of sequence '.$seq_id.'...');

      $sf->sequences()->[$index]->sortFeatures();
   }
}
