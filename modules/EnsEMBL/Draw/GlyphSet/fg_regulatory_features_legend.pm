=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2017] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Draw::GlyphSet::fg_regulatory_features_legend;

### Legend for regulatory features track

use strict;

use base qw(EnsEMBL::Draw::GlyphSet::legend);

sub _init {
  my $self = shift;

  ## Hide if corresponding tracks are all off
  my $node = $self->{'config'}->get_node('regulatory_features');
  return unless $node;
  my $show = 0;
  foreach ($node->descendants) {
    if ($_->get('display') && $_->get('display') ne 'off') {
      $show = 1;
      last;
    }
  }
  return unless $show; 
 
  my @features = @{$self->{'legend'}{'fg_regulatory_features_legend'}{'entries'}||[]};
  my @activities = @{$self->{'legend'}{'fg_regulatory_features_legend'}{'activities'}||[]};

  # Let them accumulate in structure if accumulating and not last
  my $Config         = $self->{'config'};
  return if ($self->my_config('accumulate') eq 'yes' &&
             $Config->get_parameter('more_slices'));
  # Clear features (for next legend)
  $self->{'legend'}{[split '::', ref $self]->[-1]} = {};
  return unless @features;
  return unless $self->{'legend'}{[split '::', ref $self]->[-1]};
 
  $self->init_legend();
 
  my $empty = 1;

  foreach (@features) {
    my $legend = $self->my_colour($_, 'text'); 
    
    next if $legend =~ /unknown/i; 
  
    $self->add_to_legend({
      legend => $legend,
      colour => $self->my_colour($_),
    });
    
    $empty = 0;
  }

  unless($empty) {
    $self->add_to_legend({
      legend => 'Activity in epigenome - Inactive',
      colour => 'black',
      stripe => 'hatch_really_thick|grey90',
    });

    if (scalar @activities) {
      $self->add_space;
      foreach (@activities) {
        my $colour = $self->my_colour($_);
        my $legend = $self->my_colour($_, 'text');
        next if $legend =~ /unknown/i; 
        $self->add_to_legend({
          legend => 'Activity in epigenome - '.$legend,
          colour => $self->my_colour($_),
        });
      }
    }
  }
  
  $self->errorTrack('No Regulatory Features in this panel') if $empty;

  $self->add_space;
}

1;
