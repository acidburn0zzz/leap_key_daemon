unless defined? BASE_DIR
  BASE_DIR = File.expand_path('../..', __FILE__)
end
unless defined? LEAP_KEY_DAEMON_CONFIG
  LEAP_KEY_DAEMON_CONFIG = '/etc/leap/key_daemon.yaml'
end

module LeapKeyDaemon

  #
  # Load Config
  # this must come first, because CouchRest needs the connection defined before the models are defined.
  #
  require 'leap_key_daemon/config'
  configs = ['config/default.yaml', LEAP_KEY_DAEMON_CONFIG, ARGV.grep(/\.ya?ml$/).first]
  config = LeapKeyDaemon::Config.new(BASE_DIR, *configs)

  require 'couch_rest/changes'
  identities = CouchRest::Changes.new(config)

  identities.changed do |hash|
    config.logger.debug "Updated identity " + hash['id']
    config.logger.debug hash.inspect
  end

  identities.listen
end
