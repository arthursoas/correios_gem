module Correios
  module ReverseLogistics
    class CancelShipping < Helper
      def initialize(data = {})
        @credentials = Correios.credentials
        @show_request = data[:show_request]

        @ticket_number = data[:ticket_number]
        @ticket_type = data[:ticket_type]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(ReverseLogistics.client.call(
            :cancelar_pedido,
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
              xml['ns1'].cancelarPedido do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.numeroPedido @ticket_number
                xml.tipo reverse_shipping_type(@ticket_type)

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:cancelar_pedido_response][:cancelar_pedido]
        generate_revese_logistics_exception(response)

        {
          ticket_number: response[:objeto_postal][:numero_pedido],
          status: response[:objeto_postal][:status_pedido]
        }
      end
    end
  end
end
