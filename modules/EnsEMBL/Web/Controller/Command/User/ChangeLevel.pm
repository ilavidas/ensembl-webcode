package EnsEMBL::Web::Controller::Command::User::ChangeLevel;

use strict;
use warnings;

use Class::Std;
use CGI;

use EnsEMBL::Web::Data::User;
use EnsEMBL::Web::Data::Group;
use EnsEMBL::Web::RegObj;

use base 'EnsEMBL::Web::Controller::Command::User';

{

sub BUILD {
  my ($self, $ident, $args) = @_; 
  $self->add_filter('EnsEMBL::Web::Controller::Command::Filter::LoggedIn');
  my $cgi = new CGI;
  $self->add_filter('EnsEMBL::Web::Controller::Command::Filter::Admin', {'group_id' => $cgi->param('group_id')});
}

sub render {
  my ($self, $action) = @_;
  $self->set_action($action);
  if ($self->not_allowed) {
    $self->render_message;
  } else {
    $self->process;
  }
}

sub process {
  my $self = shift;
  my $cgi = new CGI;
  my $user = EnsEMBL::Web::Data::User->new({ id => $cgi->param('user_id') });
  my $group = EnsEMBL::Web::Data::Group->new({ id => $cgi->param('group_id') });
  $group->assign_level_to_user($user, $cgi->param('new_level'));

  $cgi->redirect($self->url('/User/Group', {'id' => $cgi->param('group_id')}) );
}

}

1;
