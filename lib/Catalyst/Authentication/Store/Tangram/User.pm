package Catalyst::Authentication::Store::Tangram::User;
use strict;
use warnings;
use base qw/Catalyst::Authentication::User/;

BEGIN {
    __PACKAGE__->mk_accessors(qw/_tangram _storage/);
}

sub new {
    my ($class, $storage, $tangram_ob) = @_;
    bless { _storage => $storage, _tangram => $tangram_ob }, $class;
}

*get_object = \&_tangram;

sub id {
    my ($self) = @_;
    return $self->_storage->id($self->_tangram);
}

1;

=head1 NAME

Catalyst::Authentication::Store::Tangram::User - A thin adapter 
to adapt any Tangram class to behave as needed by L<Catalyst::Authentication::User>

=head1 SYNOPSIS

    $c->user->id; # Returns unique user ID
    $c->user->get('email_address'); # Retrieve value from the underlying Tangram object.
    $c->user->_tangram; # Get the underlying Tangram object yourself.

=head1 DESCRIPTION 

The Catalyst::Authentication::Store::Tangram::User class encapsulates any Tangram class in the 
L<Catalyst::Authentication::User> interface.

=head1 METHODS

=head2 new ($class, $storage, $tangram_object)

Simple constructor

=head2 id

Unique Tangram ID for this object

=head1 AUTHOR

Tomas Doran, <bobtfish at bobtfish dot net>

With thanks to state51, my employer, for giving me the time to work on this.

=head1 BUGS

No known bugs.

=head1 COPYRIGHT

Copyright (c) 2008, state51. Some rights reserved.

This module is free software; you can use, redistribute, and modify it under the same terms as Perl 5.8.x.
