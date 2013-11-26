LeapKeyDaemon - Managing PGP Keys for the LEAP platform
------------------------------------------------------------

``leap_key_deamon`` will upload pgp keys to the keyservers when they have are added to the LEAP Platform. It watches the changes made to the corresponding database. This way it will at some point be able to sign the keys in isolation from the other leap services to protect the providers private key.

This program is written in Ruby and is distributed under the following license:

> GNU Affero General Public License
> Version 3.0 or higher
> http://www.gnu.org/licenses/agpl-3.0.html

Installation
---------------------

Prerequisites:

    sudo apt-get install ruby ruby-dev couchdb
    # for development, you will also need git, bundle, and rake.

From source:

    git clone git://leap.se/leap_key_daemon
    cd leap_key_daemon
    bundle
    rake build
    sudo rake install

From gem:

    sudo gem install leap_key_daemon

Running
--------------------

Run once:

    leap_key_daemon --run-once
    This will upload all public keys created since the last run.

Run in foreground to see if it works:

    leap_key_daemon run -- test/config/config.yaml
    browse to http://localhost:5984/_utils

How you would run normally in production mode:

    leap_key_daemon start
    leap_key_daemon stop

See ``leap_key_daemon --help`` for more options.


Configuration
---------------------

``leap_key_daemon`` reads the following configurations files, in this order:

* ``$(leap_key_daemon_source)/config/default.yaml``
* ``/etc/leap/key_daemon.yaml``
* Any file passed to ARGV like so ``leap_key_daemon start -- /etc/leap_key_daemon.yaml``

For development on a couch with admin party you can probably leave all options at their default values. For production you will need to set the credentials to a user that can follow the respective databases changes.

The default options and some explaination can be found in config/defaults.yaml

Rake Tasks
----------------------------

    rake -T         # List all rake tasks
    rake build      # Build leap_key_daemon-x.x.x.gem into the pkg directory
    rake install    # Install leap_key_daemon-x.x.x.gem into either system-wide or user gems
    rake test       # Run tests (default)
    rake uninstall  # Uninstall leap_key_daemon-x.x.x.gem from either system-wide or user gems

Development
--------------------

For development and debugging you might want to run the programm directly without
the deamon wrapper. You can do this like this:

    ruby -I lib lib/leap_key_daemon.rb

