require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Pricefier
    class CalculatePrice < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @service_codes = data[:service_codes]
        @source_zip_code = data[:source_zip_code]
        @target_zip_code = data[:target_zip_code]
        @object = data[:object]
        @own_hands = data[:own_hands]
        @receipt_notification = data[:receipt_notification]
        @declared_value = data[:declared_value]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:calc_preco,
                                             soap_action: 'http://tempuri.org/CalcPreco',
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
              xml['ns1'].CalcPreco do
                xml.nCdEmpresa @credentials.administrative_code
                xml.sDsSenha @credentials.sigep_password
                xml.nCdServico HELPER.format_service_codes(@service_codes)
                xml.sCepOrigem @source_zip_code
                xml.sCepDestino @target_zip_code
                xml.nCdFormato HELPER.object_type(@object[:type])
                xml.nVlPeso @object[:weight].to_f/1000
                xml.nVlComprimento @object[:length] || 0
                xml.nVlAltura @object[:height] || 0
                xml.nVlLargura @object[:width] || 0
                xml.nVlDiametro @object[:diameter] || 0
                xml.sCdMaoPropria HELPER.convert_bool_to_string(@own_hands)
                xml.sCdAvisoRecebimento HELPER.convert_bool_to_string(
                  @receipt_notification
                )
                xml.nVlValorDeclarado @declared_value || 0
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:calc_preco_response][:calc_preco_result]

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
