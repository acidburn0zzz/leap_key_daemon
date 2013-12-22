$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "leap_key_daemon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leap_key_daemon"
  s.version     = LeapKeyDaemon::VERSION
  s.authors     = ["Azul"]
  s.email       = ["azul@leap.se"]
  s.homepage    = "https://leap.se"
  s.summary     = "LeapKeyDaemon - manage keys on the server side of the LEAP Platform"
  s.description = "Watches the couch database for changes to the pgp keys and uploads new keys to the keyservers when needed."

  s.files = Dir["{config,lib}/**/*", 'bin/*'] + ["Rakefile", "Readme.md"]
  s.test_files = Dir["test/**/*"]
  s.bindir = 'bin'
  s.executables << 'leap_key_daemon'

  s.add_dependency "couchrest", "~> 1.1.3"
  s.add_dependency "couchrest_changes", "~> 0.0.2"
  s.add_dependency "daemons"
  s.add_dependency "yajl-ruby"
  s.add_dependency "syslog_logger", "~> 2.0.0"
  s.add_development_dependency "minitest", "~> 3.2.0"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rake"
  s.add_development_dependency "highline"
end
