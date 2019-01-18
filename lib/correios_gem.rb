require_relative 'sigep/requests/search_zip_code'
require_relative './authentication'

module Correios
  def self.test
    'YAY! Correios-gem is working! Have fun!'
  end

  def self.credentials
    @credentials ||= Authentication.new
  end

  module Pricefier
  end

  module ReverseLogistics
  end

  module Sigep
    def self.search_zip_code(data = {})
      SearchZipCode.new(data).request
    end
  end

  module SRO
  end
end
