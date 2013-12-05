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
  CouchRest::Changes::Config.load(BASE_DIR, *configs)
  logger = LeapKeyDaemon.logger = CouchRest::Changes::Config.logger

  identities = CouchRest::Changes.new('identities')

  identities.changed do |hash|
    logger.debug "Updated identity " + hash['id']
    logger.debug hash.inspect
  end

  identities.listen
end
