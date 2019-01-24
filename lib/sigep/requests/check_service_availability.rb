require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class CheckServiceAvailability < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @service_code = data[:service_code]
        @source_zip_code = data[:source_zip_code]
        @target_zip_code = data[:target_zip_code]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:verifica_disponibilidade_servico,
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
              xml['ns1'].verificaDisponibilidadeServico do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.numeroServico @service_code
                xml.cepOrigem @source_zip_code
                xml.cepDestino @target_zip_code
                xml.codAdministrativo @credentials.administrative_code
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:verifica_disponibilidade_servico_response][:return]
        response = response.split('#')

        { 
          status: convert_availability_to_symbol(response[0]),
          message: response[1]
        }
      end

      def convert_availability_to_symbol(availability)
        case availability.to_i
        when 0, 11
          :available
        when -2, -3
          :invalid_zip_code
        when -33
          :system_down
        when -34, -35, 1
          :incorrect_data
        when -36, -37, -38
          :unauthorized
        when -888, 6, 7, 8, 9, 12
          :unavailable
        when 10
          :partially_available
        when 99
          :error
        end
      end
    end
  end
end
