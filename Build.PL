use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
  module_name        => 'Travis::Bio::Pipeline',
  licence            => 'perl',
  dist_author        => 'Travis Harrods <travis.harrods@gmail.com>',
  dist_abstract      => 'A module to create and launch pipelines for biological sequences.',
  dist_version_from  => 'lib/Travis/Bio/Pipeline.pm',
  requires           => {
    'Moose'          => 0,
    'Travis::Utilities::Log' => 0.01,
    'Travis::Bio::SequenceFactory' => 0.01
  },
  meta_merge => {
    ressources => {
      repository => 'https://github.com/TravisHarrods/Travis-Bio-Pipeline'
    }
  },
  create_makefile_pl => 'traditional',
  installdir         => 'vendor'
);

$builder->create_build_script();
