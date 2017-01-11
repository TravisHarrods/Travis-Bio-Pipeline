package  Travis::Bio::Pipeline::Plugin::IO;
use Moose;
use Travis::Utilities::Log;

extends "Travis::Bio::Pipeline::Plugin";

my $log = Travis::Utilities::Log->new();

#==============================================================================
# BUILD
#==============================================================================
sub BUILD
{
   my $self = shift;
   $self->name('IO');
   $self->description('IO plugin provide basic Input/Output methods.');
}

#==============================================================================
# METHODS
#==============================================================================
# Write all file into output path
sub writeAll {
   my $self = shift;
   my $sf   = shift; # the sequence factory

   $sf->writeSequences();
}
