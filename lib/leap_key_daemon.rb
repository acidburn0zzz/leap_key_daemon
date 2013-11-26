unless defined? BASE_DIR
  BASE_DIR = File.expand_path('../..', __FILE__)
end
unless defined? LEAP_KEY_DAEMON_CONFIG
  LEAP_KEY_DAEMON_CONFIG = '/etc/leap/key_daemon.yaml'
end

module LeapKeyDaemon
  class <<self
    attr_accessor :logger
  end

  #
  # Load Config
  # this must come first, because CouchRest needs the connection defined before the models are defined.
  #
  require 'leap_key_daemon/config'
  LeapKeyDaemon::Config.load(BASE_DIR, 'config/default.yaml', LEAP_KEY_DAEMON_CONFIG, ARGV.grep(/\.ya?ml$/).first)

  require 'couch_rest/changes'

  LeapKeyDaemon.logger.info "Observing #{Config.couch_host_without_password}"
  LeapKeyDaemon.logger.info "Tracking #{Config.identities_db_name}"
  db = CouchRest.new(Config.couch_host).database(Config.identities_db_name)
  identities = CouchRest::Changes.new db,
    :seq_filename => Config.seq_file,
    :logger => LeapKeyDaemon.logger

  identities.changed do |hash|
    LeapKeyDaemon.logger.debug "Updated identity " + hash['id']
    LeapKeyDaemon.logger.debug hash.inspect
  end

  identities.listen
end
