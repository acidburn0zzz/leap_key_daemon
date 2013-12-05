require 'yaml'

module CouchRest
  class Changes
    module Config
      extend self

      attr_accessor :connection
      attr_accessor :seq_file
      attr_accessor :log_file
      attr_writer :log_level
      attr_accessor :logger
      attr_accessor :options

      def load(base_dir, *configs)
        @base_dir = base_dir
        loaded = configs.collect do |file_path|
          file = find_file(file_path)
          load_config(file)
        end
        init_logger
        log_loaded_configs(loaded.compact)
        logger.info "Observing #{couch_host_without_password}"
      end

      def couch_host(conf = nil)
        conf ||= connection
        userinfo = [conf[:username], conf[:password]].compact.join(':')
        userinfo += '@' unless userinfo.empty?
        "#{conf[:protocol]}://#{userinfo}#{conf[:host]}:#{conf[:port]}"
      end

      def couch_host_without_password
        couch_host connection.merge({:password => nil})
      end

      def complete_db_name(db_name)
        [connection[:prefix], db_name, connection[:suffix]].
         compact.
         reject{|part| part == ""}.
         join('_')
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
        load_settings YAML.load(File.read(file_path)), file_path
        return file_path
      end

      def load_settings(hash, file_path)
        return unless hash
        hash.each do |key, value|
          begin
            apply_setting(key, value)
          rescue NoMethodError => exc
            # log might not have been configured yet correctly
            # so better also print this
            STDERR.puts "Error in file #{file_path}"
            STDERR.puts "'#{key}' is not a valid option"
            init_logger
            logger.warn "Error in file #{file_path}"
            logger.warn "'#{key}' is not a valid option"
            logger.debug exc
          end
        end
      end

      def apply_setting(key, value)
        if value.is_a? Hash
          value = symbolize_keys(value)
        end
        self.send("#{key}=", value)
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

      def log_level
        @log_level || 'info'
      end
    end
  end
end
