package Travis::Bio::Pipeline::Plugin;

#==============================================================================
# Travis::Bio::Pipeline::Plugin is the main plugin class that is inherited 
# in each sub-plugin of the validator tool.
#
# Author: Hugo Devillers
# Created: 18-JUN-2015
# Updated: 10-JAN-2017
#==============================================================================

#==============================================================================
# REQUIERMENTS
#==============================================================================
use Moose;

use Travis::Utilities::Log;
my $log = Travis::Utilities::Log->new();

#==============================================================================
# ATTRIBUTS
#==============================================================================
# Plugin name
has 'name'  => (
   is       => 'rw',
   isa      => 'Str',
   default  => ''
);


# Short description of the plugin
has 'description' => (
   is             => 'rw',
   isa            => 'Str',
   default        => 'No description available.'
);

# Raw argument list (string)
has 'raw_arguments' => (
   is      => 'rw',
   isa     => 'Str',
   default => ''
);

# Parsed arguments (Hash)
has 'arguments' => (
   traits   => ['Hash'],
   is       => 'rw',
   isa      => 'HashRef',
   default  => sub{ {} },
   handles  => {
                  setArgument => 'set',
                  getArgument => 'get',
                  hasArgument => 'exists'
               }
);


#==============================================================================
# BUILDER
#==============================================================================
sub BUILD {
   my $self = shift;

   $self->_parseRawArguments();
}


#==============================================================================
# PRIVATE METHODS
#==============================================================================
sub _parseRawArguments {
   my $self = shift;

   # If raw arguements are provide, parse it!
   if( $self->raw_arguments() ne '' ) {
      # Split between arguements
      my @arg_kv = split(/\s{0,},\s{0,}/, $self->raw_arguments() );

      # Scan each pairs (key/value)
      foreach my $kv (@arg_kv) {
         my ($arg, $value) = split(/\s{0,}=\s{0,}/, $kv);

         # TODO: argument over-wirte check?
         $arg =~ s/\s//g;

         $self->setArgument( $arg => $value );

      }
   }
}


#==============================================================================
# PUBLIC METHODS
#==============================================================================
# The default run function
sub run {
   my $self = shift;

   $log->warning('No run instruction provided');
}

no Moose;
return(1);
