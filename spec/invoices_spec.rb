require 'spec_helper'

describe 'invoices' do
  let(:ifirma) { ifirma = Ifirma.new(:config => { :username => "drogus", :invoices_key => "AABB" }) }

  it "sends an invoice" do
    payload = {
      :paid             => 0,
      :type             => :net,
      :account_no       => "11 1100 1100 1100 1100 1100 1100",
      :issue_date       => Date.new(2011, 10, 20),
      :sale_date        => Date.new(2011, 10, 21),
      :sale_date_format => :daily,
      :due_date         => Date.new(2011, 11, 20),
      :payment_type     => :wire,
      :designation_type => "BPO",
      :gios             => false,
      :number           => nil,
      :customer         => {
        :name    => "joe",
        :nip     => "333-333-33-33",
        :street  => "Marszalkowska",
        :zipcode => "12-345",
        :city    => "Warszawa",
        :email   => "joe@example.org",
        :phone   => "123456789"
      },
      :items => [{
        :vat_rate => 7,
        :quantity => 10,
        :price    => 100,
        :name     => "Development",
        :unit     => "hour",
        :vat_type => :percent
      }]
    }

    body = {
      "Zaplacono"            => 0,
      "LiczOd"               => "NET",
      "NumerKontaBankowego"  => "11110011001100110011001100",
      "DataWystawienia"      => "2011-10-20",
      "DataSprzedazy"        => "2011-10-21",
      "FormatDatySprzedazy"  => "DZN",
      "TerminPlatnosci"      => "2011-11-20",
      "SposobZaplaty"        => "PRZ",
      "RodzajPodpisuOdiorcy" => "BPO",
      "WidocznyNumerGios"    => false,
      "Numer"                => nil,
      "Kontrahent"           => {
        "Nazwa"       => "joe",
        "NIP"         => "333-333-33-33",
        "Ulica"       => "Marszalkowska",
        "KodPocztowy" => "12-345",
        "Miejscowosc" => "Warszawa",
        "Email"       => "joe@example.org",
        "Telefon"     => "123456789"
      },
      "Pozycje" => [{
        "StawkaVat"       => "0.07",
        "Ilosc"           => 10,
        "CenaJednostkowa" => 100,
        "NazwaPelna"      => "Development",
        "Jednostka"       => "hour",
        "TypStawkiVat"    => "PRC"
      }]
    }
    body = Yajl::Encoder.encode(body)

    headers = {
      'Accept' => 'application/json',
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=cac3f3f986f8ef75fdb310ba6bf40c56422c29fe',
      'Content-Type' => 'application/json; charset=utf-8',
      'User-Agent' => 'Ruby'
    }

    stub_request(:post, "https://www.ifirma.pl/iapi/fakturakraj.json").
      with(:headers => headers, :body => body)

    ifirma.create_invoice(payload)
  end
end
