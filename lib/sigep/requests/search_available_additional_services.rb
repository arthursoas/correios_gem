require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class SearchAvailableAdditionalServices < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize
        @show_request = data[:show_request]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:busca_servicos_adicionais_ativos,
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
              xml['ns1'].buscaServicosAdicionaisAtivos
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:busca_servicos_adicionais_ativos_response][:return]
        response = [response] if response.is_a?(Hash)

        { additional_services: format_additional_services(response) }
      end

      def format_additional_services(additional_services)
        formatted_additional_services = []
        additional_services.each do |additional_service|
          formatted_additional_services << {
            code: additional_service[:codigo],
            description: additional_service[:descricao].encode(Encoding::UTF_8),
            initials: additional_service[:sigla]
          }
        end
        formatted_additional_services
      end
    end
  end
end
