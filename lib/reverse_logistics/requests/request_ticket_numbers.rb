module Correios
  module ReverseLogistics
    class RequestTicketNumbers < Helper
      ENVIRONMENT = ReverseLogisticsEnvironment.new

      def initialize(data = {})
        @credentials = Correios.credentials
        @show_request = data[:show_request]

        @ticket_type = data[:ticket_type]
        @service = data[:service]
        @amount = data[:amount]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(ENVIRONMENT.client.call(
            :solicitar_range,
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
              xml['ns1'].solicitarRange do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.tipo ticket_type(@ticket_type)
                xml.servico reverse_shipping_service(@service)
                xml.quantidade @amount

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:solicitar_range_response][:solicitar_range]
        generate_revese_logistics_exception(response)

        initial_number = response[:faixa_inicial].to_i
        final_number = response[:faixa_final].to_i

        ticket_numbers = []
        while initial_number <= final_number do
          ticket_numbers << initial_number.to_s
          initial_number += 1
        end

        { ticket_numbers: ticket_numbers }
      end
    end
  end
end
