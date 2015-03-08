use strict;
use warnings;
BEGIN {
    unless ( $ENV{RIAK_PBC_HOST} ) {
        require Test::More;
        Test::More::plan(
            skip_all => 'variable RIAK_PBC_HOST is not defined' );
    }
}

use Test::More;
use Test::Exception;
use AnyEvent::Riak;


plan tests => 2;

my ( $host, $port ) = split ':', $ENV{RIAK_PBC_HOST};
my @buckets_to_cleanup = ( qw(foo) );


subtest "connection" => sub {
    plan tests => 2;

    my $cv1 = AE::cv;
    my $client = AnyEvent::Riak->new(
        on_connect       => sub { pass("client connected"); $cv1->send },
        on_connect_error => sub { fail("client not connected"); $cv1->croak($_[1])},
    );
    $cv1->recv;
    ok($client, "client created");
};

subtest "simple get/set/delete test" => sub {
    plan tests => 1;

    my ( $host, $port ) = split ':', $ENV{RIAK_PBC_HOST};
    my $cv1 = AE::cv;
    my $client = AnyEvent::Riak->new(
        on_connect       => sub { $cv1->send },
        on_connect_error => sub { $cv1->croak($_[1]) },
    );
    $cv1->recv;

    my $scalar = '3.14159';

    # make sure we run stuff with callbacks as well

    my $cv2 = AE::cv;
    $client->put({ bucket => 'bucket_name',
                   key => 'bar',
                   return_body => 1,
                   content => { value => "plop", content_type => 'text/plain' } },
                 sub {
                     my ($result, $err) = @_;
                     $err and $cv2->croak($err->{error_message});
                     $cv2->send($result);
                     ok("put plop");
                 } );
    $cv2->recv();
    # is($client->get(     foo => 'bar'  ), $hash,     "fetch hashref" );
    # ok(       $client->put_raw( foo => "bar2"  , $scalar ), "store raw scalar");
    # is(       $client->get_raw( foo => 'bar2' ), $scalar,   "fetch raw scalar");
    # ok(       $client->exists(  foo => 'bar'  ),            "should exists" );
    # ok(       $client->del(     foo => 'bar'  ),            "delete hashref" );
    # ok(      !$client->get(     foo => 'bar'  ),            "fetches nothing" );

#     ok( !$client->exists( foo => 'bar' ), "should not exists" );

#     ok( $client->put( foo => "baz", 'TEXT', 'plain/text' ),
#         "should store the text in Riak"
#     );
#     is( $client->get( foo => "baz" ), 'TEXT',
#         "should fetch the text from Riak"
#     );

#     #ok(!$@, "should has no error - foo => bar is undefined");
};

# subtest "get keys" => sub {
#     plan tests => 5;

#     my $bucket = "foo_" . int( rand(1024) ) . "_" . int( rand(1024) );
#     push @buckets_to_cleanup, $bucket;

#     my ( $host, $port ) = split ':', $ENV{RIAK_PBC_HOST};

#     my $client = Riak::Client->new(
#         host => $host, port => $port,
#     );

#     my @keys;
#     $client->get_keys( $bucket => sub { push @keys, $_[0] } );

#     foreach my $key (@keys) {
#         $client->del( $bucket => $key );
#     }
#     my $hash = { a => 1 };

#     $client->put( $bucket => "bar", $hash );
#     $client->put( $bucket => "baz", $hash );
#     $client->put( $bucket => "bam", $hash );

#     @keys = ();
#     $client->get_keys( $bucket => sub { push @keys, $_[0] } );
#     my @keys_without_callback = @{ $client->get_keys( $bucket ) // [] };

#     @keys = sort @keys;
#     is( scalar @keys, 3 );
#     is( scalar @keys_without_callback, 3 );
#     is( $keys[0],     'bam' );
#     is( $keys[1],     'bar' );
#     is( $keys[2],     'baz' );
# };

# my $nb = 10;
# subtest "sequence of $nb get/set" => sub {
#     plan tests => $nb;

#     my ( $host, $port ) = split ':', $ENV{RIAK_PBC_HOST};

#     my $client = Riak::Client->new(
#         host => $host, port => $port,
#     );

#     my $hash = {
#         foo       => bar  => baz     => 123,
#         something => very => complex => [ 1, 2, 3, 4, 5 ]
#     };

#     my ( $bucket, $key );
#     for ( 1 .. $nb ) {
#         ( $bucket, $key ) =
#           ( "bucket" . int( rand(1024) ), "key" . int( rand(1024) ) );

#         push @buckets_to_cleanup, $bucket;

#         $hash->{random} = int( rand(1024) );

#         $client->put( $bucket => $key => $hash );

#         my $got_complex_structure = $client->get( $bucket => $key );
#         is_deeply(
#             $got_complex_structure, $hash,
#             "get($bucket=>$key)should got the same structure"
#         );
#     }
# };

# subtest "get buckets" => sub {
#     plan tests => 4;

#     my ( $host, $port ) = split ':', $ENV{RIAK_PBC_HOST};

#     my $client = Riak::Client->new(
#         host => $host, port => $port,
#     );

#     my @new_buckets = (
#         "foo_" . int( rand(1024) ) . "_" . int( rand(1024) ),
#         "foo_" . int( rand(1024) ) . "_" . int( rand(1024) ),
#         "foo_" . int( rand(1024) ) . "_" . int( rand(1024) ),
#     );

#     push @buckets_to_cleanup, @new_buckets;

#     my @exp_buckets = ( @{ $client->get_buckets() // [] }, @new_buckets);

#     my $key = "key" . int( rand(1024) );
#     my $hash = { a => 1 };
#     $client->put( $_ => $key => $hash ) foreach (@new_buckets);

#     my @buckets = @{ $client->get_buckets() // [] };
#     is( scalar @buckets, scalar @exp_buckets );

#     foreach my $bucket (@new_buckets) {
#         is(grep( $bucket eq $_, @buckets), 1, "bucket $bucket is found");
#     }

# };

# subtest "get/set buckets props" => sub {
#     plan tests => 4;

#     my ( $host, $port ) = split ':', $ENV{RIAK_PBC_HOST};

#     my $client = Riak::Client->new(
#         host => $host, port => $port,
#     );

#     my @buckets = (
#         "foo_" . int( rand(1024) ) . "_" . int( rand(1024) ),
#         "foo_" . int( rand(1024) ) . "_" . int( rand(1024) ),
#         "foo_" . int( rand(1024) ) . "_" . int( rand(1024) ),
#     );

#     push @buckets_to_cleanup, @buckets;

#     my $key = "key" . int( rand(1024) );
#     my $hash = { a => 1 };
#     my $exp_props = { n_val => 1, allow_mult => 0 };
#     foreach (@buckets) {
#         $client->put( $_ => $key => $hash );
#         $client->set_bucket_props($_, $exp_props);
#     }

#     my @props = map { $client->get_bucket_props($_) } @buckets;

#     is( scalar @props, scalar @buckets);
#     is_deeply($_, $exp_props, "wrong props structure") foreach (@props);
# };

# END {

#     diag "\ncleaning up...";
#     my $client = Riak::Client->new(
#         host => $host, port => $port,
#     );
#     my $another_client = Riak::Client->new(
#         host => $host, port => $port,
#     );

#     my $c = 0;
#     foreach my $bucket (@buckets_to_cleanup) {
#         $client->get_keys($bucket => sub{
#                               my $key = $_; # also in $_[0]
#                               # { local $| = 1; print "."; }
#                               $c++;
#                               $another_client->del($bucket => $key);
#                           });
#     }

#     diag "done (deleted $c keys).";

# }
