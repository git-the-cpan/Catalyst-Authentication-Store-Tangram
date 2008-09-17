package Catalyst::Authentication::Store::Tangram;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use Scalar::Util qw/blessed/;
use Catalyst::Authentication::Store::Tangram::User;

our $VERSION = '0.001';

BEGIN {
    __PACKAGE__->mk_accessors(qw/tangram_model user_class storage_method/);
}

sub new {
    my ($class, $config, $app, $realm) = @_;
    die("user_class key must be defined in config")
        unless $config->{user_class};
    $config->{tangram_model} ||= 'Tangram';
    $config->{storage_method} ||= 'storage';
    bless { %$config }, $class;
}

sub find_user {
    my ($self, $authinfo, $c) = @_;
    my $user_class = $self->user_class;
    my $storage = $c->model($self->tangram_model)->${\$self->storage_method}();
    my $remote = $storage->remote($user_class);
    my $filter;
    foreach my $key (keys %$authinfo) {
        $filter = (defined $filter
            ? ($filter & $remote->{$key} eq $authinfo->{$key})
            : $remote->{$key} eq $authinfo->{$key}
        );
    }
    my @result = $storage->select($remote, filter => $filter);
    if (@result) {
        return Catalyst::Authentication::Store::Tangram::User->new($storage, $result[0]);
    }
    return;
}

sub for_session {
    my ($self, $user) = @_;
    return $user->id;
}

sub from_session {
    my ($self, $id) = @_;
    my $user_class = $self->user_class;
    my $tangram_user;
    eval { $tangram_user = $user_class->load($id) }; # FIXME - does this work in regular Tangram?
    return if $@ or !$tangram_user;
    return Catalyst::Authentication::Store::Tangram::User->new($tangram_user);
}

sub user_supports {
    my ($class) = @_;
    return;
}

1;

=head1 NAME

Catalyst::Authentication::Store::Tangram - A storage class for Catalyst authentication from a class stored in Tangram

=head1 SYNOPSIS

    use Catalyst qw/
        Authentication
    /;

    __PACKAGE__->config( authentication => {  
        default_realm => 'members',
        realms => {
            members => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'clear'
                },
                store => {
                    class => 'Tangram',
                    user_class => 'Users',
                    tangram_model => 'Tangram',
                    storage_method => 'storage', # $c->model('Tangram')->storage                
                },
            },
        },
    });

    # Log a user in:
    sub login : Global {
        my ( $self, $c ) = @_;

        $c->authenticate({  
            email_address => $c->req->param('email_address'),
            password => $c->req->param('password'),
        });
    }

=head1 DESCRIPTION 

The Catalyst::Authentication::Store::Tangram class provides access to authentication 
information stored in a database via L<Tangram>.

=head1 CONFIGURATION

The Tangram authentication store is activated by setting the store config's class element 
to I<Tangram> as shown above. See the L<Catalyst::Plugin::Authentication> documentation 
for more details on configuring the store.

The Tangram storage module has several configuration options

    authentication => {  
        default_realm => 'members',
        realms => {
            members => {
                credential => {
                    # ...
                },
                store => {
                    class => 'Tangram',
                    user_class => 'Users',
                    tangram_model => 'Tangram',
                    storage_method => 'storage', # $c->model('Tangram')->storage                
                },
            },
        },
    }
    
=over

=item class

Class is part of the core L<Catalyst::Plugin::Authentication> module, it contains the class name of the store to be used.

=item user_class

Contains the class name of the class persisted in your Tangram schema to use as the source for user information. 
This config item is B<REQUIRED>. This class name is used to get a Tangram remote object when constructing a search
for your user when first authenticating, and also this is the class which the ->load method is called on to restore 
the user from a session.

=item tangram_model

Contains the class name (as passed to $c->model()) of the Tangram model to use as the source for user information. 
This config item is REQUIRED. The I<storage_method> method will be invoked on this class to get the L<Tangram::Storage>
instance to restore the user from.

=item storage_method

Contains the method to call on the I<tangram_model> to retrieve the instance of L<Tangram::Storage> which users are
looked up from.

=back

=head1 METHODS

=head2 new ( $config, $app, $realm )

Simple constructor, returns a blessed reference to the store object instance.

=head2 find_user ( $authinfo, $c )

I<$auth_info> is expected to be a hash with the keys being field names on your Tangram user object, and the values
being what those fields should be matched against. A tangram select will be built from the supplied auth info, and this
select is used to retrieve the user from Tangram.

=head2 for_session ( $c, $user )

This method returns the Tangram ID for the user, as that is all that is necessary to be persisted in the session
to restore the user.

=head2 from_session ( $c, $frozenuser )

This method is called whenever a user is being restored from the session. $frozenuser contains the Tangram ID of
the user to restore.

=head2 user_supports ( $feature, ... )

Returns false.

=head1 AUTHOR

Tomas Doran, <bobtfish at bobtfish dot net>

With thanks to state51, my employer, for giving me the time to work on this.

=head1 BUGS

No known bugs. However this module could be significantly more feature filled.

Please report bugs through the rt.cpan.org bug tracker.

=head1 COPYRIGHT

Copyright (c) 2008, state51. Some rights reserved.

This module is free software; you can use, redistribute, and modify it under the same terms as Perl 5.8.x.
