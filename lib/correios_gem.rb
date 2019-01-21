require_relative 'sigep/requests/search_zip_code'
require_relative 'sigep/requests/search_customer'
require_relative 'sigep/requests/create_shippings'
require_relative 'credentials'

module Correios
  def self.test
    'YAY! Correios-gem is working! Have fun!'
  end

  def self.authenticate
    yield(credentials)
  end

  def self.credentials
    @credentials ||= Credentials.new
  end

  module Pricefier
  end

  module ReverseLogistics
  end

  module Sigep
    def self.search_zip_code(data = {})
      SearchZipCode.new(data).request
    end

    def self.search_customer
      SearchCustomer.new.request
    end

    def self.create_shippings(data = {})
      CreateShippings.new(data).request
    end
  end

  module SRO
  end
end
