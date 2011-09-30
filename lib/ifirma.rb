require 'openssl'
require 'faraday'
require 'faraday_stack'

require 'ifirma/version'
require 'ifirma/auth_middleware'

class Ifirma
  def initialize(options = {})
    configure(options)
  end

  def configure(options)
    raise "Please provide config data" unless options[:config]

    @invoices_key = options[:config][:invoices_key]
    @username     = options[:config][:username]
  end

private

  def connection
    @connection ||= begin
      Faraday.new(:url => 'https://www.ifirma.pl/') do |builder|
        builder.use FaradayStack::ResponseJSON, :content_type => 'application/json'
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Request::JSON
        builder.use Ifirma::AuthMiddleware, :username => @username, :invoices_key => @invoices_key
#        builder.use Faraday::Response::Logger
        builder.use Faraday::Adapter::NetHttp
      end
    end
  end
end
