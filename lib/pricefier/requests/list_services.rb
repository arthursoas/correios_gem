require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Pricefier
    class ListServices < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @show_request = data[:show_request]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:calc_preco,
                                             soap_action: 'http://tempuri.org/ListaServicos',
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
              xml['ns1'].ListaServicos
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:lista_servicos_response][:lista_servicos_result]

        services = response[:servicos_calculo][:c_servicos_calculo]
        services = [services] if services.is_a?(Hash)

        formatted_services = []
        services.each do |service|
          formatted_services << format_service(service)
        end

        {
          services: formatted_services
        }
      end

      def format_service(service)
        if service[:erro].to_i == 0
          {
            code: service[:codigo],
            description: service[:descricao].strip,
            calculate_price: HELPER.convert_string_to_bool(
              service[:calcula_preco]
            ),
            calculate_deadline: HELPER.convert_string_to_bool(
              service[:calcula_prazo]
            )
          }
        else
          {
            code: service[:codigo],
            error: {
              code: service[:erro],
              description: service[:msg_erro]
            }
          }
        end
      end
    end
  end
end
