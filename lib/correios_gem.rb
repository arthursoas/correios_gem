require_relative 'sigep/requests/cancel_shipping'
require_relative 'sigep/requests/calculate_label_number_check_digit'
require_relative 'sigep/requests/check_card_status'
require_relative 'sigep/requests/check_service_availability'
require_relative 'sigep/requests/create_shippings'
require_relative 'sigep/requests/request_label_numbers'
require_relative 'sigep/requests/request_shippings_xml'
require_relative 'sigep/requests/search_available_additional_services'
require_relative 'sigep/requests/search_customer'
require_relative 'sigep/requests/search_zip_code'
require_relative 'sigep/requests/track_shippings'
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
    def self.calculate_label_number_check_digit(data = {})
      CalculateLabelNumberCheckDigit.new(data).request
    end

    def self.cancel_shipping(data = {})
      CancelShipping.new(data).request
    end

    def self.check_card_status(data = {})
      CheckCardStatus.new(data).request
    end

    def self.check_service_availability(data = {})
      CheckServiceAvailability.new(data).request
    end

    def self.create_shippings(data = {})
      CreateShippings.new(data).request
    end

    def self.request_label_numbers(data = {})
      RequestLabelNumbers.new(data).request
    end

    def self.request_shippings_xml(data = {})
      RequestShippingsXML.new(data).request
    end

    def self.search_available_additional_services(data = {})
      SearchAvailableAdditionalServices.new(data).request
    end

    def self.search_customer(data = {})
      SearchCustomer.new(data).request
    end

    def self.search_zip_code(data = {})
      SearchZipCode.new(data).request
    end

    def self.track_shippings(data = {})
      TrackShippings.new(data).request
    end
  end

  module SRO
  end
end
