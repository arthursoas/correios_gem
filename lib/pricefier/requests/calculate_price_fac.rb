require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Pricefier
    class CalculatePriceFAC < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @show_request = data[:show_request]
        @service_codes = data[:service_codes]
        @weight = data[:weight]
        @reference_date = data[:reference_date]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:calc_preco_fac,
                                             soap_action: 'http://tempuri.org/CalcPrecoFAC',
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
              xml['ns1'].CalcPrecoFAC do
                xml.nCdServico HELPER.format_service_codes(@service_codes)
                xml.nVlPeso @weight
                xml.strDataCalculo HELPER.convert_date_to_string(
                  @reference_date
                )
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:calc_preco_fac_response][:calc_preco_fac_result]

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
            prices: {
              additional_serivces: {
                own_hands: HELPER.convert_string_to_float(
                  service[:valor_mao_propria]
                ),
                receipt_notification: HELPER.convert_string_to_float(
                  service[:valor_aviso_recebimento]
                ),
                declared_value: HELPER.convert_string_to_float(
                  service[:valor_valor_declarado]
                ),
              },
              only_shipping: HELPER.convert_string_to_float(
                service[:valor_sem_adicionais]
              ),
              total: HELPER.convert_string_to_float(service[:valor])
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
