require 'openssl'
require 'faraday'
require 'faraday_stack'
require 'yajl'

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

  [:get, :post, :put, :delete, :head].each do |method|
    define_method(method) do |*args, &block|
      connection.send(method, *args, &block)
    end
  end

  def create_invoice(attrs)
    post "/iapi/fakturakraj.json", normalize_attributes_for_request(attrs)
  end

  ATTRIBUTES_MAP = {
    :paid             => "Zaplacono",
    :type             => "LiczOd",
    :account_no       => "NumerKontaBankowego",
    :issue_date       => "DataWystawienia",
    :sale_date        => "DataSprzedazy",
    :sale_date_format => "FormatDatySprzedazy",
    :due_date         => "TerminPlatnosci",
    :payment_type     => "SposobZaplaty",
    :designation_type => "RodzajPodpisuOdiorcy",
    :gios             => "WidocznyNumerGios",
    :number           => "Numer",
    :customer         => {
      :customer => "Kontrahent",
      :name     => "Nazwa",
      :nip      => "NIP",
      :street   => "Ulica",
      :zipcode  => "KodPocztowy",
      :city     => "Miejscowosc",
      :email    => "Email",
      :phone    => "Telefon"
    },
    :items => {
      :items    => "Pozycje",
      :vat_rate => "StawkaVat",
      :quantity => "Ilosc",
      :price    => "CenaJednostkowa",
      :name     => "NazwaPelna",
      :unit     => "Jednostka",
      :vat_type => "TypStawkiVat"
    }
  }

  DATE_MAPPER = lambda { |value| value.strftime("%Y-%m-%d") }

  VALUE_MAP = {
    :issue_date => DATE_MAPPER,
    :sale_date  => DATE_MAPPER,
    :due_date   => DATE_MAPPER,
    :account_no => lambda { |value| value.tr(" ", "") },
    :type => {
      :net   => "NET",
      :gross => "BRT"
    },
    :payment_type => {
      :wire        => "PRZ",
      :cash        => "GTK",
      :offset      => "KOM",
      :on_delivery => "POB"
    },
    :sale_date_format => {
      :daily   => "DZN",
      :monthly => "MSC"
    },
    :items => {
      :vat_type => {
        :percent => "PRC",
        :exempt  => "ZW"
      },
      :vat_rate => lambda { |value| (value.to_f / 100).to_s },
    }
  }

private

  def normalize_attributes_for_request(attrs, result = {}, map = ATTRIBUTES_MAP, value_map = VALUE_MAP)
    attrs.each do |key, value|
      if value.is_a? Array
        nested_key = map[key][key]
        result[nested_key] = []
        value.each do |item|
          result[nested_key] << normalize_attributes_for_request(item, {}, map[key], value_map[key] || {})
        end
      elsif value.is_a? Hash
        nested_key = map[key][key]
        result[nested_key] = {}
        normalize_attributes_for_request(attrs[key], result[nested_key], map[key], value_map[key] || {})
      else
        translated = map[key]
        result[translated] = normalize_attribute(value, value_map[key])
      end
    end

    result
  end

  def normalize_attribute(value, mapper)
    return value unless mapper

    if mapper.respond_to?(:call)
      mapper.call(value)
    else
      mapper[value]
    end
  end

  def connection
    @connection ||= begin
      Faraday.new(:url => 'https://www.ifirma.pl/') do |builder|
        builder.use FaradayStack::ResponseJSON, :content_type => 'application/json'
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Request::JSON
        builder.use Ifirma::AuthMiddleware, :username => @username, :invoices_key => @invoices_key
#        builder.use Faraday::Response::Logger
        builder.use Faraday::Adapter::NetHttp
      end.tap do |connection|
        connection.headers["Content-Type"] = "application/json; charset=utf-8"
        connection.headers["Accept"]       = "application/json"

      end
    end
  end
end
