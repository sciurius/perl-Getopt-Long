my $name = "TestApp";

our $app =
  { name         => $name,
    version      => "0.02",
    configs      =>
    { sysconfig  => [ "/", "etc", lc($name).".conf" ],
      userconfig => [ '$ENV{HOME}', ".".lc($name), "config" ],
      config     => "." . lc($name) . ".conf",
    },
    clo          =>
    [
     [ "process-incoming|pi", 0, "Process incoming" ],
     [ "process-pre-incoming|ppi", 0, "Process pre-incoming" ],
     [ "bar=s", "xx", "Drinks of <WHISKEY> please" ],
     [ "count=i", 0, "Maximum <MAX:count>" ],
    ],
  };

1;

__END__

use App;

my $cfg = App->setup($app);

main($cfg);

or:

sub main {
    my $cfg = shift;
    ...
}

App->run($app);
