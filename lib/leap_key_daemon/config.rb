require 'yaml'

module LeapKeyDaemon
  class Config

    attr_accessor :identities_db_name
    attr_accessor :couch_connection
    attr_accessor :seq_file
    attr_accessor :log_file
    attr_accessor :log_level
    attr_accessor :logger

    def initialize(base_dir, *configs)
      @base_dir = base_dir
      loaded = configs.collect do |file_path|
        file = find_file(file_path)
        load_config(file)
      end
      init_logger
      log_loaded_configs(loaded.compact)
    end

    def couch_host(conf = nil)
      conf ||= couch_connection
      userinfo = [conf[:username], conf[:password]].compact.join(':')
      userinfo += '@' unless userinfo.empty?
      "#{conf[:protocol]}://#{userinfo}#{conf[:host]}:#{conf[:port]}"
    end

    def couch_host_without_password
      couch_host couch_connection.merge({:password => nil})
    end

    private

    def init_logger
      if log_file
        require 'logger'
        @logger = Logger.new(log_file)
      else
        require 'syslog/logger'
        @logger = Syslog::Logger.new('leap_key_daemon')
      end
      @logger.level = Logger.const_get(log_level.upcase)
    end

    def load_config(file_path)
      return unless file_path
      load_settings YAML.load(File.read(file_path))
      return file_path
    rescue NoMethodError => exc
      init_logger
      logger.fatal "Error in file #{file_path}"
      logger.fatal exc
      exit(1)
    end

    def load_settings(hash)
      return unless hash
      hash.each do |key, value|
        apply_setting(key, value)
      end
    end

    def apply_setting(key, value)
      if value.is_a? Hash
        value = self.class.symbolize_keys(value)
      end
      self.send("#{key}=", value)
    rescue NoMethodError => exc
      STDERR.puts "'#{key}' is not a valid option"
      raise exc
    end

    def self.symbolize_keys(hsh)
      newhsh = {}
      hsh.keys.each do |key|
        newhsh[key.to_sym] = hsh[key]
      end
      newhsh
    end

    def find_file(file_path)
      return nil unless file_path
      if defined? CWD
        return File.expand_path(file_path, CWD)  if File.exists?(File.expand_path(file_path, CWD))
      end
      return File.expand_path(file_path, @base_dir) if File.exists?(File.expand_path(file_path, @base_dir))
      return nil
    end

    def log_loaded_configs(files)
      files.each do |file|
        logger.info "Loaded config from #{file} ."
      end
    end
  end
end
