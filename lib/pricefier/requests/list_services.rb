module Correios
  module Pricefier
    class ListServices < Helper
      def initialize(data = {})
        @show_request = data[:show_request]
        super()
      end

      def request(method)
        @method = method
        @method_snake = method.underscore

        puts xml if @show_request == true
        begin
          format_response(Pricefier.client.call(
            @method_snake.to_sym,
            soap_action: "http://tempuri.org/#{@method}",
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
          xml['soap'].Envelope(Pricefier.namespaces) do
            xml['soap'].Body do
              xml['ns1'].send(@method)
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response["#{@method_snake}_response".to_sym]["#{@method_snake}_result".to_sym]

        services = response[:servicos_calculo][:c_servicos_calculo]
        services = [services] if services.is_a?(Hash)

        { services: services.map { |s| format_service(s) } }
      end

      def format_service(service)
        if service[:erro].to_i.zero?
          {
            code: service[:codigo],
            description: service[:descricao].strip,
            calculate_price: string_to_bool(service[:calcula_preco]),
            calculate_deadline:
              if service[:calcula_prazo].present?
                string_to_bool(service[:calcula_prazo])
              else
                false
              end
          }
        else
          {
            code: service[:codigo],
            error: { code: service[:erro],
                     description: service[:msg_erro] }
          }
        end
      end
    end
  end
end
