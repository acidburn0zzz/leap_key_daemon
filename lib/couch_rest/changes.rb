require 'couchrest'
require 'fileutils'

module CouchRest
  class Changes

    attr_accessor :db

    def initialize(db, config)
      @db = db
      @seq_filename = config[:seq_filename]
      @logger = config[:logger]
      read_seq(@seq_filename)
    end

    # triggered when a document was newly created
    def created(hash = {}, &block)
      run_or_define_hook :created, hash, &block
    end

    # triggered when a document was deleted
    def deleted(hash = {}, &block)
      run_or_define_hook :deleted, hash, &block
    end

    # triggered when an existing document was updated
    def updated(hash = {}, &block)
      run_or_define_hook :updated, hash, &block
    end

    # triggered whenever a document was changed
    def changed(hash = {}, &block)
      run_or_define_hook :changed, hash, &block
    end

    def listen
      @logger.info "listening..."
      @logger.debug "Starting at sequence #{since}"
      db.changes :feed => :continuous, :since => since, :heartbeat => 1000 do |hash|
        callbacks(hash)
        store_seq(hash["seq"])
      end
    end

    protected

    def since
      @since ||= 0  # fetch_last_seq
    end

    def callbacks(hash)
      return unless changes = hash["changes"]
      changed(hash)
      return deleted(hash) if hash["deleted"]
      return created(hash) if changes[0]["rev"].start_with?('1-')
      updated(hash)
    end

    def run_or_define_hook(event, hash = {}, &block)
      @callbacks ||= {}
      if block_given?
        @callbacks[event] = block
      else
        @callbacks[event] && @callbacks[event].call(hash)
      end
    end

    def read_seq(seq_filename)
      @logger.debug "Looking up sequence here: #{seq_filename}"
      FileUtils.touch(seq_filename)
      unless File.writable?(seq_filename)
        raise StandardError.new("Can't access sequence file")
      end
      @since = File.read(seq_filename).to_i
      @logger.debug "Found sequence: #{@since}"
    rescue Errno::ENOENT => e
      @logger.warn "No sequence file found. Starting from scratch"
    end

    def store_seq(seq)
      File.write(@seq_filename, seq)
    end

    #
    # UNUSED: this is useful for only following new sequences.
    #
    def fetch_last_seq
      hash = db.changes :limit => 1, :descending => true
      @logger.info "starting at seq: " + hash["last_seq"]
      return hash["last_seq"]
    end

  end
end
