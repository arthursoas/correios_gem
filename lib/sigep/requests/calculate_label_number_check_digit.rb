require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class CalculateLabelNumberCheckDigit < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @label_numbers = data[:label_numbers]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:gera_digito_verificador_etiquetas,
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
              xml['ns1'].geraDigitoVerificadorEtiquetas do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                @label_numbers.each do |label_number|
                  xml.etiquetas label_number
                end
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:gera_digito_verificador_etiquetas_response][:return]
        response = [response] if response.is_a?(Hash)

        { digit_checkers: format_digit_checkers(response) }
      end

      def format_digit_checkers(digit_checkers)
        formatted_digit_checkers = []
        digit_checkers.each do |digit_check|
          formatted_digit_checkers << digit_check.to_i
        end
        formatted_digit_checkers
      end
    end
  end
end
