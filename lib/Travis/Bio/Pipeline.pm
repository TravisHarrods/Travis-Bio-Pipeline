package Travis::Bio::Pipeline;

#==============================================================================
#  Travis::Bio::Pipeline is the main package for the BioPerl framework.
#
# Author: Hugo Devillers, Travis Harrods
# Created: 14-MAR-2016
# Updated: 11-JAN-2017
#==============================================================================

#==============================================================================
# REQUIERMENTS
#==============================================================================
use Moose;
use Travis::Utilities::Log;
use Travis::Utilities::Files;

# Inherit from sequenceFactory
extends 'Travis::Bio::SequenceFactory';

# Plugin manager
use Module::Pluggable sub_name => 'search_plugins', require => 1;

my $log = Travis::Utilities::Log->new();

#==============================================================================
# ATTRIBUTS
#==============================================================================
our $VERSION = 0.01;
# Available plugins
has 'plugins' => (
   traits  => ['Hash'],
   is      => 'rw',
   isa     => 'HashRef',
   default => sub{ {} },
   handles => {
                  hasPlugin  => 'exists',
                  setPlugin  => 'set',
                  getPlugin  => 'get',
                  allPlugins => 'kv'
              }
);

# Path to user plugin directory
has 'user_plugins' => (
  is      => 'ro',
  isa     => 'Str',
  default => ''
);

# Pipeline instructions
has 'pipeline' => (
   is      => 'rw',
   isa     => 'Str',
   default => ''
);

#==============================================================================
# BUILDER
#==============================================================================
sub BUILD {
  my $self = shift;

  # Load buildin plugins
  my @plugins = $self->search_plugins();
  $self->_loadPlugins(\@plugins, 'Build-in');

  # Load user plugins (if necessary)
  if( $self->user_plugins() ne '' ) {

      # Look for plugin(s) from the provided path
      $self->search_path( new => $self->user_plugins() );
      @plugins = $self->search_plugins();

      if( scalar(@plugins) > 0 ) {
        # Load the found plugins
        $self->_loadPlugins(\@plugins, 'User');
      } else {
        $log->warning('The provided path ('.$self->user_plugins().
          ') does not contain any plugin or it is not a regular path.');
      }
  }


}

#==============================================================================
# TRIGGERS
#==============================================================================

#==============================================================================
# PRIVATE METHODS
#==============================================================================
sub _loadPlugins {
   my $self    = shift;
   my $plugins = shift; # An Array of plugin paths
   my $source  = shift;

   # Si aucune source fournie
   if(!defined($source)) {
      $source = 'Unknown';
   }

   # Scan and load each plugin path and store it
   foreach my $path (@{$plugins}) {
      # Create a instance of the plugin object
      my $p = $path->new();

      # Get its names
      my $p_name = $p->name();

      if( $self->hasPlugin($p_name) ) {
         $log->error('Cannot load plugin from '.$path.': plugin name ('.$p_name.
            ') already used.');
      }
      else {
         $self->setPlugin( $p_name => {
                                          path   => $path,
                                          source => $source
                                       } );

      }
   }
}

# Check if the povided pipeline is a file and load it
sub _lookForPipelineFile {
   my $self = shift;

   # Get the pipeline string
   my $pl = $self->pipeline();

   if( $pl ne '' ) {
      if( -f $pl ) {
         # the pipeline input corresponds to a file path
         my $inline_pl = '';
         open(PIP, $pl) or $log->fatal('Cannot open pipeline file '.$pl.'.');
         while( my $line = <PIP> ) {
            chomp($line);
            # Lines starting with # are comments
            if( ($line!~/#/) & ($line ne '') ) {
               if( $line!~/^\s+$/ ) {
                  $inline_pl .= $line.'+';
               }
            }
         }
         close(PIP);

         # Remove the last '+';
         chop($inline_pl);

         # Replace inline instruction
         $self->pipeline($inline_pl);
      }
   }
}

#==============================================================================
# PUBLIC METHODS
#==============================================================================
# List of available plugins (loaded in plugins attribute)
sub listPlugins {
   my $self = shift;

   # TODO: make a nice display function
   foreach my $plug_data ($self->allPlugins()) {
      # Create an empty intance of the plugin
      my $p = $plug_data->[1]->{'path'}->new();

      print $plug_data->[0]."\t".$plug_data->[1]->{'source'}."\t".
         $p->description()."\n";

   }
}

# execute pipeline
sub executePipeline {
   my $self = shift;

   # Load pipeline file if required
   $self->_lookForPipelineFile();

   my $pl = $self->pipeline();

   if( $pl ne '' ) {
      # Split pl to obtain the different plugin to launch
      my @pipeline_list = split(/\s{0,}\+\s{0,}/, $pl);

      while( scalar(@pipeline_list) > 0 ) {
         # Get the "next" plugin command
         my $plugin_cmd = shift @pipeline_list;

         # Split it to identify plugin name and arg. list
         my ($plugin_name, $args) = split(/\s{0,}:\s{0,}/, $plugin_cmd);

         # if no args is provided switch undef into empty string
         if( !defined($args) ) {
            $args = '';
         }

         # Check for specific method name to run
         my $run_method = 'run';
         if( $plugin_name =~ /^(\w+)\[(\w+)\]$/ ) {
            $plugin_name = $1;
            $run_method = $2;
         }

         # Check if plugin can be loaded
         if( $self->hasPlugin($plugin_name) ) {
            my $plugin_data = $self->getPlugin($plugin_name);

            # Create the corresponding plugin object
            my $p = $plugin_data->{'path'}->new(
               raw_arguments => $args
            );

            # Check if the queried method exists
            if( $p->can($run_method) ) {
               $log->info('* Running method '.$run_method.' from plugin '.
                $plugin_name.'...');
               # Run it and catch potential callback
               my $callback = $p->$run_method( $self );

               # Insert the callback into the pipeline list
               if( $callback ) {
                 if( $callback ne '1' ) {
                  my @cb_list = split(/\s{0,}\+\s{0,}/, $callback);
                  unshift @pipeline_list, @cb_list;
                }
               }
            }
            else {
               $log->fatal('No method '.$run_method.' in plugin '.$plugin_name.'.');
            }

         }
         else {
            $log->fatal('Unknown plugin '.$plugin_name.'.');
         }

      }

   }
   else {
      $log->warning('No pipeline instruction provided.')
   }

}

no Moose;

return(1);
