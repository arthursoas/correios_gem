module Correios
  module ReverseLogistics
    class TrackShipping < Helper
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
          format_response(ReverseLogistics.client.call(
            :acompanhar_pedido,
            soap_action: '',
            xml: xml
          ).to_hash)
        rescue Savon::SOAPFault => error
          generate_soap_fault_exception(error)
        rescue Savon::HTTPError => error
          generate_http_exception(error.http.code)
        end
      end

      private

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(ReverseLogistics.namespaces) do
            xml['soap'].Body do
              xml['ns1'].acompanharPedido do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.numeroPedido @ticket_number
                xml.tipoSolicitacao reverse_shipping_type(@type)
                xml.tipoBusca reverse_tracking_result_type(@result_type)

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:acompanhar_pedido_response][:acompanhar_pedido]
        generate_revese_logistics_exception(response)

        events = response[:coleta][:historico]
        events = [events] if events.is_a?(Hash)

        objects = response[:coleta][:objeto]
        objects = [objects] if objects.is_a?(Hash)

        {
          ticket_number: response[:coleta][:numero_pedido],
          type: inverse_reverse_shipping_type(
            response[:tipo_solicitacao]
          ),
          code: response[:coleta][:controle_cliente],
          events: events.map {|e| format_event(e)},
          objects: objects.map {|o| format_object(o)}
        }
      end

      def format_event(event)
        {
          status: event[:status],
          description: event[:descricao_status],
          time: string_to_time(
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
            time: string_to_time(
              object[:data_ultima_atualizacao], object[:hora_ultima_atualizacao]
            )
          }
        }
      end
    end
  end
end
