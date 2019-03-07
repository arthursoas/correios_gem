require 'active_support/core_ext/hash'

module Correios
  module Sigep
    class TrackShippings < Helper
      def initialize(data = {})
        @credentials = Correios.credentials
        @show_request = data[:show_request]

        @label_numbers = data[:label_numbers]
        @query_type = data[:query_type]
        @result_type = data[:result_type]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(Sigep.client.call(
            :consulta_sro,
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
          xml['soap'].Envelope(Sigep.namespaces) do
            xml['soap'].Body do
              xml['ns1'].consultaSRO do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                @label_numbers.each do |label_number|
                  xml.listaObjetos label_number
                end
                xml.tipoConsulta tracking_query_type(@query_type)
                xml.tipoResultado tracking_result_type(@result_type)
                xml.usuarioSro @credentials.sro_user
                xml.senhaSro @credentials.sro_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:consulta_sro_response][:return]
        response = Hash.from_xml(response)

        objects = response['rastro']['objeto']
        objects = [objects] if objects.is_a?(Hash)

        { tracking: objects.map {|o| format_object(o)} }
      end

      def format_object(object)
        events = object['evento']
        events = [events] if events.is_a?(Hash)

        {
          label: {
            number: object['numero'],
            initials: object['sigla'],
            name: object['nome'],
            category: object['categoria']
          },
          events: events.map {|e| format_event(e)}
        }
      end

      def format_event(event)
        {
          movement: inverse_tracking_event_status(event),
          type: event['tipo'],
          status: event['status'],
          time: string_to_time_no_second(event['data'], event['hora']),
          description: event['descricao'],
          detail: event['detalhe'],
          city: event['cidade'],
          state: event['uf'],
          destination: format_destination(event['destino']),
          site: {
            description: event['local'],
            zip_code: event['codigo']
          }
        }
      end

      def format_destination(destination)
        return nil if destination.nil?
        {
          city: destination['cidade'],
          neighborhood: destination['bairro'],
          state: destination['uf'],
          site: {
            description: destination['local'],
            zip_code: destination['codigo']
          }
        }
      end
    end
  end
end
