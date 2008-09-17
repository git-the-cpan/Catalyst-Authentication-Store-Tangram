package TestApp;
use strict;
use warnings;

use Catalyst qw/
    Authentication
/;

__PACKAGE__->config(
    authentication => {
        default_realm => 'test',
        realms => {
            test => {
                credential => {
                    class          => 'Password',
                    password_field => 'password',
                    password_type  => 'clear',
                },
                store => {
                    class => 'Tangram',
                    user_class => 'Users',
                },
            },
        },
    },   
);

__PACKAGE__->setup;

1;
