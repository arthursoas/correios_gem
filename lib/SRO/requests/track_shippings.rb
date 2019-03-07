module Correios
  module SRO
    class TrackShippings < Helper
      def initialize(data = {})
        @credentials = Correios.credentials
        @show_request = data[:show_request]

        @label_numbers = data[:label_numbers]
        @query_type = data[:query_type]
        @result_type = data[:result_type]
        @language = data[:language]
        super()
      end

      def request(method)
        @method = method
        @method_snake = method.underscore

        puts xml if @show_request == true
        begin
          format_response(SRO.client.call(
            @method_snake.to_sym,
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
          xml['soap'].Envelope(SRO.namespaces) do
            xml['soap'].Body do
              xml['ns1'].send(@method) do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                if @method == 'buscaEventosLista'
                  @label_numbers.each do |label_number|
                    xml.objetos label_number
                  end
                elsif @method == 'buscaEventos'
                  xml.objetos array_to_string(@label_numbers)
                end
                xml.tipo tracking_query_type(@query_type)
                xml.resultado tracking_result_type(@result_type)
                xml.lingua tracking_language(@language)
                xml.usuario @credentials.sro_user
                xml.senha @credentials.sro_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response["#{@method_snake}_response".to_sym][:return]
        objects = response[:objeto]
        objects = [objects] if objects.is_a?(Hash)
        generate_sro_exception(objects)

        { tracking: objects.map {|o| format_object(o)} }
      end

      def format_object(object)
        if object[:erro].present?
          return { 
            label: {
              number: object[:numero]
            },
            error: object[:erro]
          }
        end

        events = object[:evento]
        events = [events] if events.is_a?(Hash)

        {
          label: {
            number: object[:numero],
            initials: object[:sigla],
            name: object[:nome],
            category: object[:categoria]
          },
          events: events.map {|e| format_event(e)}
        }
      end

      def format_event(event)
        {
          movement: inverse_tracking_event_status(event),
          type: event[:tipo],
          status: event[:status],
          time: string_to_time_no_second(event[:data], event[:hora]),
          description: event[:descricao],
          detail: event[:detalhe],
          city: event[:cidade],
          state: event[:uf],
          destination: format_destination(event[:destino]),
          site: {
            description: event[:local],
            zip_code: event[:codigo]
          }
        }
      end

      def format_destination(destination)
        return nil if destination.nil?
        {
          city: destination[:cidade],
          neighborhood: destination[:bairro],
          state: destination[:uf],
          site: {
            description: destination[:local],
            zip_code: destination[:codigo]
          }
        }
      end
    end
  end
end
