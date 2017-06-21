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

package EnsEMBL::Draw::Style::Feature::MultiBlocks;

=pod

Renders a track as a series of rectangular blocks, each of which may
consist of a number of blocks in different colours. For example regulatory
features showing motifs, flanks, etc.

=cut

use parent qw(EnsEMBL::Draw::Style::Feature);


sub draw_feature {
### @param feature Hashref - data for a single feature
### @param position Hashref - information about the feature's size and position
  my ($self, $feature, $position) = @_;

  return unless ($feature->{'colour'});
  my $total_height = $position->{'height'};

  ## Set parameters
  my $x = $feature->{'start'};
  $x    = 0 if $x < 0;
  my $params = {
                  x           => $x,
                  y           => $position->{'y'},
                  width       => $position->{'width'},
                  height      => $position->{'height'},
                  href        => $feature->{'href'},
                  title       => $feature->{'title'},
                  colour      => $feature->{'colour'},
                  absolutey   => 1,
                };
  #use Data::Dumper; warn Dumper($params);

  push @{$self->glyphs}, $self->Rect($params);

  ## Draw internal structure, e.g. motif features
  if ($feature->{'structure'} && $self->track_config->get('display_structure')) {
    foreach my $element (@{$feature->{'structure'}}) {
      push @{$self->glyphs}, $self->Rect({
          x         => $element->{'start'} - 1,
          y         => $position->{'y'},
          height    => $position->{'height'},
          width     => $element->{'end'} - $element->{'start'} + 1,
          absolutey => 1,
          colour    => 'black',
        });
    }
  }

  return $total_height;
}

1;
