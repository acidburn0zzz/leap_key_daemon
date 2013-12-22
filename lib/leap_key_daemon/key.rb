module LeapKeyDaemon
  class Key
    def initialize(doc)
      return unless doc.respond_to? :[]
      @armored = doc['keys']['pgp'] if doc['keys'].respond_to? :[]
    end

    def present?
      !!@armored
    end

    def upload
      return unless present?
      response = Net::HTTP.post_form keyserver, keytext: @armored
      process_response(response)
      return true
    end

    protected

    def process_response(response)
      case response
      when Net::HTTPInternalServerError
        logger.warn "Invalid Key"
        logger.debug @armored
      when Net::HTTPOK
        logger.debug "Uploaded key"
      else
        logger.info response.inspect
      end
    end

    def logger
      LeapKeyDaemon.logger
    end

    def keyserver
      URI(LeapKeyDaemon.config.options[:keyserver] + '/pks/add')
    end
  end
end


