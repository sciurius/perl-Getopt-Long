################ Object Oriented routines ################

package Getopt::Long;

# NOTE: The object oriented routines use $error for thread locking.
eval "sub lock{}" if $] < 5.005;

# Store a copy of the default configuration. Since ConfigDefaults has
# just been called, what we get from Configure is the default.
my $default_config = do { lock ($error); Configure () };

sub new {
    my $that = shift;
    my $class = ref($that) || $that;

    # Register the callers package.
    my $self = { caller => (caller)[0] };

    bless ($self, $class);

    # Process construct time configuration.
    if ( @_ > 0 ) {
	lock ($error);
	my $save = Configure ($default_config, @_);
	$self->{settings} = Configure ($save);
    }
    # Else use default config.
    else {
	$self->{settings} = $default_config;
    }

    $self;
}

sub configure {
    my ($self) = shift;

    lock ($error);

    # Restore settings, merge new settings in.
    my $save = Configure ($self->{settings}, @_);

    # Restore orig config and save the new config.
    $self->{settings} = Configure ($save);
}

sub getoptions {
    my ($self) = shift;

    lock ($error);

    # Restore config settings.
    my $save = Configure ($self->{settings});

    # Call main routine.
    my $ret = 0;
    $caller = $self->{caller};
    eval { $ret = GetOptions (@_); };

    # Restore saved settings.
    Configure ($save);

    # Handle errors and return value.
    die ($@) if $@;
    return $ret;
}

1;
