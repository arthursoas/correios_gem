require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Pricefier
    class CalculateDeadlineWithDate < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @show_request = data[:show_request]
        @service_codes = data[:service_codes]
        @source_zip_code = data[:source_zip_code]
        @target_zip_code = data[:target_zip_code]
        @reference_date = data[:reference_date]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:calc_prazo_data,
                                             soap_action: 'http://tempuri.org/CalcPrazoData',
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
              xml['ns1'].CalcPrazoData do
                xml.nCdServico HELPER.format_service_codes(@service_codes)
                xml.sCepOrigem @source_zip_code
                xml.sCepDestino @target_zip_code
                xml.sDtCalculo HELPER.convert_date_to_string(@reference_date)
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:calc_prazo_data_response][:calc_prazo_data_result]

        services = response[:servicos][:c_servico]
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
        if [0, 10, 11].include?(service[:erro].to_i)
          {
            code: service[:codigo],
            delivery_at_home: HELPER.convert_string_to_bool(
              service[:entrega_domiciliar]
            ),
            delivery_on_saturdays: HELPER.convert_string_to_bool(
              service[:entrega_sabado]
            ),
            note: service[:obs_fim],
            deadline: {
              days: service[:prazo_entrega].to_i,
              date: HELPER.convert_string_to_date(
                service[:data_max_entrega]
              ),
            }
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
