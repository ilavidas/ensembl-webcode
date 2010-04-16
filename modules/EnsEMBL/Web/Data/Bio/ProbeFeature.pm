package EnsEMBL::Web::Data::Bio::ProbeFeature;

### NAME: EnsEMBL::Web::Data::Bio::ProbeFeature
### Base class - wrapper around a Bio::EnsEMBL::ProbeFeature API object 

### STATUS: Under Development
### Replacement for EnsEMBL::Web::Object::ProbeFeature

### DESCRIPTION:
### This module provides additional data-handling
### capabilities on top of those provided by the API

use strict;
use warnings;
no warnings qw(uninitialized);

use base qw(EnsEMBL::Web::Data::Bio);

sub convert_to_drawing_parameters {
### Converts a set of API objects into simple parameters 
### for use by drawing code and HTML components
  my $self = shift;
  my $data = $self->data_objects;
  my $results = [];

  foreach my $probe (@$data) {
    if (ref($probe) =~ /UnmappedObject/) {
      my $unmapped = $self->unmapped_object($probe);
      push(@$results, $unmapped);
    }
    else {
      my $names = join ' ', map { /^(.*):(.*):\2/? "$1:$2" : $_ } sort @{$probe->get_all_complete_names()};
      foreach my $f (@{$probe->get_all_ProbeFeatures()}) {
        push @$results, {
          'region'   => $f->seq_region_name,
          'start'    => $f->start,
          'end'      => $f->end,
          'strand'   => $f->strand,
          'length'   => $f->end-$f->start+1,
          'label'    => $names,
          'gene_id'  => [$names],
          'extra'    => [ $f->mismatchcount, $f->cigar_string ]
        }
      }
    }
  }
  return [$results, ['Mismatches', 'Cigar String'], 'ProbeFeature'];

}

1;
