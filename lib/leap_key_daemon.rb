unless defined? BASE_DIR
  BASE_DIR = File.expand_path('../..', __FILE__)
end
unless defined? LEAP_KEY_DAEMON_CONFIG
  LEAP_KEY_DAEMON_CONFIG = '/etc/leap/key_daemon.yaml'
end

module LeapKeyDaemon

  class << self
    attr_accessor :logger
  end

  #
  # Load Config
  # this must come first, because CouchRest needs the connection defined before the models are defined.
  #
  require 'couchrest/changes'
  configs = ['config/default.yaml', LEAP_KEY_DAEMON_CONFIG, ARGV.grep(/\.ya?ml$/).first]
  config = CouchRest::Changes::Config.new(BASE_DIR, *configs)
  LeapKeyDaemon.logger = config.logger

  identities = CouchRest::Changes.new(config)

  identities.changed do |hash|
    config.logger.debug "Updated identity " + hash['id']
    config.logger.debug hash.inspect
  end

  identities.listen
end
