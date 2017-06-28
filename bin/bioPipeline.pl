#!/usr/bin/env perl

=pod

=head1 NAME

bioPipeline.pl - Main script to launch bioPipeline tools.

=cut

use 5.014;
use strict;
use warnings;

use Getopt::Long;
use Pod::Usage qw(pod2usage);

use Travis::Utilities::Log;
use Travis::Bio::Pipeline;

my $log = Travis::Utilities::Log->new();

my $input  = ''; # An input path (single file, list of files, directory, ...)
my $output = ''; # An output path to a directory
my $format = ''; # A standard file format
my $user_plugins = ''; # A path to user additional plugins
my $pipeline = '';
my $list_plugins; # Boolean indicating if plugin list had to be shown
my $help;

eval {
   GetOptions(
      '-input|i=s'        => \$input,
      '-output|o=s'       => \$output,
      '-format|f=s'       => \$format,
      '-pipeline|p=s'     => \$pipeline,
      '-user-plugins|u=s' => \$user_plugins,
      '-list-plugins|l'   => \$list_plugins,
      '-help|h'           => \$help
   );
};
if( $@ ) {
   $log->fatal('Argument value error: '.$@);
}
# Show usage
if( defined($help) ) {
  pod2usage( -verbose => 1 );
}
# Only show the list of plugins
if( defined($list_plugins) ) {
  my $bs = Travis::Bio::Pipeline->new(
    user_plugins => $user_plugins
  );
  $bs->listPlugins();
  exit(1);
}

# No help or plugin list asked
if($input eq '') {
  $log->fatal('You must provide an input path/file.');
}

$log->info('Reading input sequences...');
my $bs = Travis::Bio::Pipeline->new(
  input            => $input,
  format           => $format,
  pipeline         => $pipeline,
  user_plugins     => $user_plugins
);


# If required, change the output directory
if( $output ne '' ) {
   $log->trace('Changing output directory...');
   $bs->changeOutputDirectories($output);
}

# Launch the pipeline
$log->info('Executing the pipeline...');
$bs->executePipeline();


#say $factory->countSequences();
#say $factory->sequences()->[0]->getOutputPath();
#$factory->writeSequence('YALI0A');

#my $seq = TRAVIS::BioSeq::sequence->new( input => $input );
#say $seq->seqId();
#$seq->setOutputPath('test.embl');
#$seq->sortFeatures();
#$seq->write();
