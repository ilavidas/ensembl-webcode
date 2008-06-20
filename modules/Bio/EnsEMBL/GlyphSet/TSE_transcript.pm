package Bio::EnsEMBL::GlyphSet::TSE_transcript;
use strict;
use vars qw(@ISA);
use Bio::EnsEMBL::GlyphSet;
@ISA = qw(Bio::EnsEMBL::GlyphSet);
use Sanger::Graphics::Glyph::Rect;
use Sanger::Graphics::Glyph::Text;
use Sanger::Graphics::Glyph::Line;
use Bio::EnsEMBL::Utils::Eprof qw(eprof_start eprof_end);
use Data::Dumper;

sub init_label {
  my ($self) = @_;
  my $sample = $self->{'config'}->{'id'};
  $self->init_label_text( $sample );
}

sub _init {
	my ($self) = @_;
#	my $offset = $self->{'container'}->start - 1;

	my $Config  = $self->{'config'};
	my $h       = 8;   #Increasing this increases glyph height

	my $colours     = $self->colours();
	my $pix_per_bp  = $Config->transform->{'scalex'};
	my $length      = $Config->container_width();

	my $trans_ref = $Config->{'transcript'};
	my $coding_start = $trans_ref->{'coding_start'};
	my $coding_end   = $trans_ref->{'coding_end'  };
	my $strand = $trans_ref->{'exons'}[0][2]->strand;

	my $transcript = $trans_ref->{'transcript'};
	my @exons = sort {$a->[0] <=> $b->[0]} @{$trans_ref->{'exons'}};

	my %highlights;
	@highlights{$self->highlights} = ();    # build hashkeys of highlight list
	my($colour, $label, $hilight) = $self->colour( $transcript, $colours, %highlights );
	
	## First of all draw the lines behind the exons.....
	foreach my $subslice (@{$Config->{'subslices'}}) {
		$self->push( new Sanger::Graphics::Glyph::Rect({
			'x' => $subslice->[0]+$subslice->[2]-1,
			'y' => $h/2,
			'h'=>1,
			'width'=>$subslice->[1]-$subslice->[0],
			'colour'=>$colour,
			'absolutey'=>1,
		}));
	}

	## Now draw the exons themselves....	
	foreach my $exon (@exons) { 
		next unless defined $exon; #Skip this exon if it is not defined (can happen w/ genscans) 

		# only draw this exon if is inside the slice (of course it really should be but no harm in checking_
		my $box_start = $exon->[0];
		$box_start    = 1 if $box_start < 1 ;
		my $box_end   = $exon->[1];
		$box_end      = $length if $box_end > $length;
		
		# calculate and draw the coding part of the exon
		my $filled_start = $box_start < $coding_start ? $coding_start : $box_start;
		my $filled_end   = $box_end   > $coding_end   ? $coding_end   : $box_end;
		if( $filled_start <= $filled_end ) {
			$self->push( new Sanger::Graphics::Glyph::Rect({
				'x'         => $filled_start -1,
				'y'         => 0,
				'width'     => $filled_end - $filled_start + 1,
				'height'    => $h,
				'colour'    => $colour,
				'absolutey' => 1
			}));
		}

		# draw a non-filled rectangle around the entire exon
		my $G = new Sanger::Graphics::Glyph::Rect({
			'x'         => $box_start -1 ,
			'y'         => 0,
			'width'     => $box_end-$box_start +1,
			'height'    => $h,
			'bordercolour' => $colour,
			'absolutey' => 1,
			'title'     => $exon->[2]->stable_id,
			'href'      => $self->href(  $transcript, $exon->[2], %highlights ),
		});
		$G->{'zmenu'} = $self->zmenu( $transcript, $exon->[2] ) unless $Config->{'_href_only'};
		$self->push( $G );
	}

	#draw a direction arrow
	if($strand == 1) {
		$self->push(new Sanger::Graphics::Glyph::Line({
			'x'         => 0,
			'y'         => -4,
			'width'     => $length,
			'height'    => 0,
			'absolutey' => 1,
			'colour'    => $colour
		}));
		$self->push( new Sanger::Graphics::Glyph::Poly({
			'points' => [
				$length - 4/$pix_per_bp,-2,
				$length                ,-4,
				$length - 4/$pix_per_bp,-6],
			'colour'    => $colour,
			'absolutey' => 1,
		}));
	} else {
		$self->push(new Sanger::Graphics::Glyph::Line({
			'x'         => 0,
			'y'         => $h+4,
			'width'     => $length,
			'height'    => 0,
			'absolutey' => 1,
			'colour'    => $colour
		}));
		$self->push(new Sanger::Graphics::Glyph::Poly({
			'points'    => [ 4/$pix_per_bp,$h+6,
							 0,              $h+4,
							 4/$pix_per_bp,$h+2],
			'colour'    => $colour,
			'absolutey' => 1,
		}));
	}
}

sub colours {
  my $self = shift;
  my $Config = $self->{'config'};
  return $Config->get('TSE_transcript','colours');
}

sub colour {
  my ($self,  $transcript, $colours, %highlights) = @_;
  my $genecol = $colours->{ $transcript->analysis->logic_name."_".$transcript->biotype."_".$transcript->status };
#  warn $transcript->stable_id,' ',$transcript->analysis->logic_name."_".$transcript->biotype."_".$transcript->status;
  if(exists $highlights{lc($transcript->stable_id)}) {
    return (@$genecol, $colours->{'hi'});
  } elsif(exists $highlights{lc($transcript->external_name)}) {
    return (@$genecol, $colours->{'hi'});
  }
 # warn @$genecol;
  return (@$genecol, undef);

}

sub href {
    my ($self, $transcript, $exon, %highlights ) = @_;

    my $tid = $transcript->stable_id();

    return "#$tid" ;
}

sub zmenu {
  my ($self, $transcript, $exon, %highlights) = @_;
  my $eid = $exon->stable_id();
  my $tid = $transcript->stable_id();
  my $pid = $transcript->translation ? $transcript->translation->stable_id() : '';
  #my $gid = $gene->stable_id();
  my $id   = $transcript->external_name() eq '' ? $tid : ( $transcript->external_db.": ".$transcript->external_name() );
  my $zmenu = {
    'caption'                       => $self->species_defs->AUTHORITY." Gene",
    "00:$id"			=> "",
#	"01:Gene:$gid"                  => "/@{[$self->{container}{_config_file_name_}]}/geneview?gene=$gid;db=core",
        "02:Transcr:$tid"    	        => "/@{[$self->{container}{_config_file_name_}]}/transview?transcript=$tid;db=core",                	
        "04:Exon:$eid"    	        => "",
        '11:Export cDNA'                => "/@{[$self->{container}{_config_file_name_}]}/exportview?options=cdna;action=select;format=fasta;type1=transcript;anchor1=$tid",
        
    };
    
    if($pid) {
    $zmenu->{"03:Peptide:$pid"}=
    	qq(/@{[$self->{container}{_config_file_name_}]}/protview?peptide=$pid;db=core);
    $zmenu->{'12:Export Peptide'}=
    	qq(/@{[$self->{container}{_config_file_name_}]}/exportview?options=peptide;action=select;format=fasta;type1=peptide;anchor1=$pid);	
    }
    return $zmenu;
}

sub text_label {
	warn "drawing label";
	return 'name';
}

sub error_track_name { return $_[0]->species_defs->AUTHORITY.' transcripts'; }

1;
