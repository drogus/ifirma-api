class Ifirma
  class Response
    attr_reader :code, :info, :invoice_id, :body, :response

    def initialize(options = {})
      @body = options
      if options.instance_of?(Hash)
        @code = options.delete("Kod")
        @info = options.delete("Informacja")
        @invoice_id = options.delete("Identyfikator")
      end
    end

    def success?
      @code == 0 || @code.nil?
    end

    def error?
      @code > 0
    end
  end
end
