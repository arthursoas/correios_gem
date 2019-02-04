require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module ReverseLogistics
    class TrackShippingsByDate < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @type = data[:type]
        @date = data[:date]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:acompanhar_pedido_por_data,
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
              xml['ns1'].acompanharPedidoPorData do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.tipoSolicitacao HELPER.shipping_type(@type)
                xml.data HELPER.convert_date_to_string(@date)

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:acompanhar_pedido_por_data_response][:acompanhar_pedido_por_data]
        generate_exception(response[:msg_erro]) if response[:cod_erro].present?

        shippings = response[:coleta]
        shippings = [shippings] if shippings.is_a?(Hash)

        formatted_shippings = []
        shippings.each do |shipping|
          formatted_shippings << format_shippping(shipping)
        end

        {
          type: HELPER.shipping_type_inverse(
            response[:tipo_solicitacao]
          ),
          shippings: formatted_shippings
        }
      end

      def format_shippping(shipping)
        events = shipping[:historico]
        events = [events] if events.is_a?(Hash)

        objects = shipping[:objeto]
        objects = [objects] if objects.is_a?(Hash)

        formatted_events = []
        events.each do |event|
          formatted_events << format_event(event)
        end

        formatted_objects = []
        objects.each do |object|
          formatted_objects << format_object(object)
        end

        {
          ticket_number: shipping[:numero_pedido],
          code: shipping[:controle_cliente],
          events: formatted_events,
          objects: formatted_objects
        }
      end

      def format_event(event)
        {
          status: event[:status],
          description: event[:descricao_status],
          time: HELPER.convert_string_to_date_time(
            event[:data_atualizacao], event[:hora_atualizacao]
          ),
          note: event[:observacao]
        }
      end

      def format_object(object)
        shipping_price = object[:valor_postagem] || 0
        {
          label_number: object[:numero_etiqueta],
          id: object[:controle_objeto_cliente],
          shipping_price: shipping_price.to_f,
          last_event: {
            status: object[:ultimo_status],
            description: object[:descricao_status],
            time: HELPER.convert_string_to_date_time(
              object[:data_ultima_atualizacao], object[:hora_ultima_atualizacao]
            )
          }
        }
      end
    end
  end
end
