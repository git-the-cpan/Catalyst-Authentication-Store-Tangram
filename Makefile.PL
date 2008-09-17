use inc::Module::Install;

name 'Catalyst-Authentication-Store-Tangram';
all_from 'lib/Catalyst/Authentication/Store/Tangram.pm';

requires 'Catalyst::Plugin::Authentication' => '0.10001';
requires 'Catalyst::Runtime' => '5.70';
requires 'Tangram' => '2.09';

build_requires 'Class::C3';
build_requires 'File::Temp';
build_requires 'DBI';
build_requires 'DBD::SQLite';
build_requires 'Test::WWW::Mechanize::Catalyst';
build_requires 'Test::More';
build_requires 'ok';

WriteAll();
