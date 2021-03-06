#!perl

use DBIx::Class::Fixtures;
use Test::More;
use lib qw(t/lib);
use DBICTest;
use Path::Class;
use Data::Dumper; 

plan tests => 16;

# set up and populate schema
ok(my $schema = DBICTest->init_schema( ), 'got schema');

my $config_dir = 't/var/configs';
my $fixture_dir = 't/var/fixtures';

# do dump
{
    ok(my $fixtures = DBIx::Class::Fixtures->new({ config_dir => $config_dir, debug => 0 }), 'object created with correct config dir');
    ok($fixtures->dump({ all => 1, schema => $schema, directory => $fixture_dir }), 'fetch dump executed okay');

    foreach my $source ($schema->sources) {
            my $rs = $schema->resultset($source);
            my $dir =  dir($fixture_dir, $rs->result_source->from);
            my @children = $dir->children;
            is (scalar(@children), $rs->count, 'all objects from $source dumped');
    }
}

# do dump with excludes
{
    ok(my $fixtures = DBIx::Class::Fixtures->new({ config_dir => $config_dir, debug => 0 }), 'object created with correct config dir');
    ok($fixtures->dump({ all => 1, schema => $schema, excludes => ['Tag'], directory => "$fixture_dir/excludes" }), 'fetch dump executed okay');

    foreach my $source ($schema->sources) {
            my $rs = $schema->resultset($source);
            next if $rs->result_source->from eq 'tags';
            my $dir =  dir("$fixture_dir/excludes", $rs->result_source->from);
            my @children = $dir->children;
            is (scalar(@children), $rs->count, 'all objects from $source dumped');
    }
}
