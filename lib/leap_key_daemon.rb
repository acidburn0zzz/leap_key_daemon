unless defined? BASE_DIR
  BASE_DIR = File.expand_path('../..', __FILE__)
end
unless defined? LEAP_KEY_DAEMON_CONFIG
  LEAP_KEY_DAEMON_CONFIG = '/etc/leap/key_daemon.yaml'
end

module LeapKeyDaemon

  class << self
    attr_accessor :logger
    attr_accessor :config
  end

  #
  # Load Config
  # this must come first, because CouchRest needs the connection defined before the models are defined.
  #
  require 'couchrest/changes'
  configs = ['config/default.yaml', LEAP_KEY_DAEMON_CONFIG, ARGV.grep(/\.ya?ml$/).first]
  self.config = CouchRest::Changes::Config.load(BASE_DIR, *configs)
  self.logger = CouchRest::Changes::Config.logger

  # hand flags over to CouchRest::Changes
  config.flags = FLAGS
  puts "flags: #{FLAGS}" if FLAGS.any?

  identities = CouchRest::Changes.new('identities')

  identities.changed do |hash|
    logger.debug "Changed identity " + hash['id']
    logger.debug hash.inspect
  end

  identities.listen
end
