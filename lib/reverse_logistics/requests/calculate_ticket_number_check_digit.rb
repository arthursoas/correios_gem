require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module ReverseLogistics
    class CalculateTicketNumberCheckDigit < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @show_request = data[:show_request]
        @ticket_number = data[:ticket_number]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:calcular_digito_verificador,
                                             soap_action: '',
                                             xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          generate_exception(error)
        end
      end

      private

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].calcularDigitoVerificador do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.numero @ticket_number

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:calcular_digito_verificador_response][:calcular_digito_verificador]
        generate_exception(response[:msg_erro]) if response[:cod_erro] != '0'

        {
          digit_checker: response[:digito],
          ticket_number: response[:numero]
        }
      end
    end
  end
end
