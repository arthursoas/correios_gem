require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module ReverseLogistics
    class RequestTicketNumbers < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @ticket_type = data[:ticket_type]
        @service = data[:service]
        @amount = data[:amount]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:solicitar_range,
                                             soap_action: '',
                                             xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          generate_exception(error)
        rescue Savon::HTTPError => error
          if error.http.code == 401
            generate_exception("Unauthorized (#{error.http.code}).")
          end
          generate_exception("Unknown HTTP error (#{error.http.code}).")
        end
      end

      private

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].solicitarRange do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.tipo ticket_type(@ticket_type)
                xml.servico service(@service)
                xml.quantidade @amount

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:solicitar_range_response][:solicitar_range]
        generate_exception(response[:msg_erro]) if response[:cod_erro] != '0'

        initial_number = response[:faixa_inicial].to_i
        final_number = response[:faixa_final].to_i

        ticket_numbers = []
        while initial_number <= final_number do
          ticket_numbers << initial_number.to_s
          initial_number += 1
        end

        { ticket_numbers: ticket_numbers }
      end

      def service(service)
        case service
        when :pac
          'LR'
        when :sedex
          'LS'
        when :e_sedex
          'LV'
        end
      end

      def ticket_type(type)
        case type
        when :authorization
          'AP'
        when :pickup
          'LR'
        end
      end
    end
  end
end
