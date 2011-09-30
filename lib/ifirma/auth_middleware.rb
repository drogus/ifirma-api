class Ifirma
  class AuthMiddleware < Faraday::Response::Middleware
    def initialize(app = nil, options = {})
      super(app)
      @options = options
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
      p data
      message_hash = OpenSSL::HMAC.digest(digest, @options[:invoices_key], data)
    end

    def username
      @options[:username]
    end
  end
end
