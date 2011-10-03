class Ifirma
  class AuthMiddleware < Faraday::Response::Middleware
    attr_reader :username, :invoices_key
    def initialize(app = nil, options = {})
      super(app)
      @options = options

      @username     = @options.delete(:username)
      @invoices_key = decode_key(@options.delete(:invoices_key))
    end

    def call(env)
      headers = env[:request_headers]

      headers["Authentication"] = authentication(env)

      @app.call(env)
    end

    private

    def authentication(env)
      "IAPIS user=#{username}, hmac-sha1=#{message_hash(env)}"
    end

    def message_hash(env)
      digest       = OpenSSL::Digest::Digest.new('sha1')
      data         = env[:url].to_s + username + "faktura" + env[:body].to_s
      message_hash = OpenSSL::HMAC.digest(digest, invoices_key, data)
      bin2hex(message_hash)
    end

    def bin2hex(str)
      str.unpack("H*").first
    end

    def decode_key(key)
      key.to_s.scan(/../).map { |hex| hex.to_i(16).chr }.join("")
    end
  end
end
