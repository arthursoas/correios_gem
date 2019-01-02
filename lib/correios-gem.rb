require_relative 'sigep/requests/query_zip_code'

module Correios
  def self.test
    'YAY! Correios-gem is working! Have fun!'
  end

  module Precifier
  end

  module ReverseLogistics
  end

  module Sigep
    def self.query_zip_code(data = {})
      QueryZipCode.new(data).request
    end
  end

  module SRO
  end
end
