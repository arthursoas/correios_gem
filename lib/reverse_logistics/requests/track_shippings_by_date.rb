module Correios
  module ReverseLogistics
    class TrackShippingsByDate < Helper
      ENVIRONMENT = ReverseLogisticsEnvironment.new

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
          format_response(ENVIRONMENT.client.call(
            :acompanhar_pedido_por_data,
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
          xml['soap'].Envelope(ENVIRONMENT.namespaces) do
            xml['soap'].Body do
              xml['ns1'].acompanharPedidoPorData do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.tipoSolicitacao reverse_shipping_type(@type)
                xml.data date_to_string(@date)

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:acompanhar_pedido_por_data_response][:acompanhar_pedido_por_data]
        generate_revese_logistics_exception(response)

        shippings = response[:coleta]
        shippings = [shippings] if shippings.is_a?(Hash)

        {
          type: inverse_reverse_shipping_type(
            response[:tipo_solicitacao]
          ),
          shippings: shippings.map {|s| format_shippping(s)}
        }
      end

      def format_shippping(shipping)
        events = shipping[:historico]
        events = [events] if events.is_a?(Hash)

        objects = shipping[:objeto]
        objects = [objects] if objects.is_a?(Hash)

        {
          ticket_number: shipping[:numero_pedido],
          code: shipping[:controle_cliente],
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
