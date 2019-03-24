require 'nokogiri'
require 'savon'

require_relative 'auxiliars/environments'
require_relative 'auxiliars/helper'
require_relative 'auxiliars/credentials'

# Post Office
require_relative 'post_office/requests/search_post_office'

# Pricefier
require_relative 'pricefier/requests/calculate_deadline'
require_relative 'pricefier/requests/calculate_price'
require_relative 'pricefier/requests/calculate_price_deadline'
require_relative 'pricefier/requests/calculate_price_fac'
require_relative 'pricefier/requests/list_services'

# Reverse Logistics
require_relative 'reverse_logistics/requests/calculate_ticket_number_check_digit'
require_relative 'reverse_logistics/requests/cancel_shipping'
require_relative 'reverse_logistics/requests/create_shippings'
require_relative 'reverse_logistics/requests/create_shippings_with_collection'
require_relative 'reverse_logistics/requests/request_ticket_numbers'
require_relative 'reverse_logistics/requests/track_shipping'
require_relative 'reverse_logistics/requests/track_shippings_by_date'

# Sigep
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

# SRO
require_relative 'SRO/requests/track_shippings'

module Correios
  def self.test
    'YAY! Correios_gem is working! Have fun!'
  end

  def self.authenticate
    yield(credentials)
  end

  def self.credentials
    @credentials ||= Credentials.new
  end

  module PostOffice
    def self.search_post_office(data = {})
      SearchPostOffice.new(data).request
    end
  end

  module Pricefier
    def self.calculate_deadline(data = {})
      CalculateDeadline.new(data).request('CalcPrazo')
    end

    def self.calculate_deadline_with_date(data = {})
      CalculateDeadline.new(data).request('CalcPrazoData')
    end

    def self.calculate_deadline_with_restrictions(data = {})
      CalculateDeadline.new(data).request('CalcPrazoRestricao')
    end

    def self.calculate_price_deadline(data = {})
      CalculatePriceDeadline.new(data).request('CalcPrecoPrazo')
    end

    def self.calculate_price_deadline_with_date(data = {})
      CalculatePriceDeadline.new(data).request('CalcPrecoPrazoData')
    end

    def self.calculate_price_deadline_with_restrictions(data = {})
      CalculatePriceDeadline.new(data).request('CalcPrecoPrazoRestricao')
    end

    def self.calculate_price(data = {})
      CalculatePrice.new(data).request('CalcPreco')
    end

    def self.calculate_price_fac(data = {})
      CalculatePriceFAC.new(data).request
    end

    def self.calculate_price_with_date(data = {})
      CalculatePriceWithDate.new(data).request('CalcPrecoData')
    end

    def self.list_services(data = {})
      ListServices.new(data).request('ListaServicos')
    end

    def self.list_services_star(data = {})
      ListServices.new(data).request('ListaServicosSTAR')
    end
  end

  module ReverseLogistics
    def self.calculate_ticket_number_check_digit(data = {})
      CalculateTicketNumberCheckDigit.new(data).request
    end

    def self.cancel_shipping(data = {})
      CancelShipping.new(data).request
    end

    def self.create_shippings(data = {})
      CreateShippings.new(data).request
    end

    def self.create_shippings_with_collection(data = {})
      CreateShippingsWithCollection.new(data).request
    end

    def self.request_ticket_numbers(data = {})
      RequestTicketNumbers.new(data).request
    end

    def self.track_shipping(data = {})
      TrackShipping.new(data).request
    end

    def self.track_shippings_by_date(data = {})
      TrackShippingsByDate.new(data).request
    end
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
    def self.track_shippings(data = {})
      TrackShippings.new(data).request('buscaEventos')
    end

    def self.track_shippings_list(data = {})
      TrackShippings.new(data).request('buscaEventosLista')
    end
  end
end
