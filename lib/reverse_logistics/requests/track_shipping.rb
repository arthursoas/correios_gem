require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module ReverseLogistics
    class TrackShipping < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @ticket_number = data[:ticket_number]
        @type = data[:type]
        @result_type = data[:result_type]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:acompanhar_pedido,
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
              xml['ns1'].acompanharPedido do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.numeroPedido @ticket_number
                xml.tipoSolicitacao HELPER.shipping_type(@type)
                xml.tipoBusca HELPER.tracking_result_type(@result_type)

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:acompanhar_pedido_response][:acompanhar_pedido]
        generate_exception(response[:msg_erro]) if response[:cod_erro].to_i != 0

        events = response[:coleta][:historico]
        events = [events] if events.is_a?(Hash)

        objects = response[:coleta][:objeto]
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
          ticket_number: response[:coleta][:numero_pedido],
          type: HELPER.shipping_type_inverse(
            response[:tipo_solicitacao]
          ),
          code: response[:coleta][:controle_cliente],
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
