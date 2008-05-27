package EnsEMBL::Web::Controller::Command::User::SaveFavourites;

use strict;
use warnings;

use Class::Std;
use CGI;

use EnsEMBL::Web::Data::SpeciesList;
use EnsEMBL::Web::Document::HTML::SpeciesList;
use EnsEMBL::Web::RegObj;

use base 'EnsEMBL::Web::Controller::Command::User';

{

sub BUILD {
  my ($self, $ident, $args) = @_; 
  $self->add_filter('EnsEMBL::Web::Controller::Command::Filter::LoggedIn');
  ## ensure that this record belongs to the logged-in user!
  my $cgi = new CGI;
  if ($cgi->param('id')) {
    $self->user_or_admin('EnsEMBL::Web::Data::Favourites', $cgi->param('id'), $cgi->param('owner_type'));
  }

}

sub render {
  my ($self, $action) = @_;
  $self->set_action($action);
  if ($self->not_allowed) {
    $self->render_message;
  } else {
    $self->render_page;
  }
}

sub render_page {
  my $self = shift;
  print "Content-type:text/html\n\n";
  my $user = $self->filters->user($EnsEMBL::Web::RegObj::ENSEMBL_WEB_REGISTRY->get_user->id);
  my @lists = @{ $user->specieslists };
  my $species_list;
  if ($#lists > -1) {
    $species_list = $lists[0];
  } else {
    $species_list = EnsEMBL::Web::Data::SpeciesList->new();
  }
  $species_list->favourites($self->get_action->get_named_parameter('favourites'));
  $species_list->list($self->get_action->get_named_parameter('list'));
  $species_list->user_id($user->id);
  $species_list->save;

  print EnsEMBL::Web::Document::HTML::SpeciesList->render("fragment");

}

}

1;
