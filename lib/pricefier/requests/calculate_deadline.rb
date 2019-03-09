module Correios
  module Pricefier
    class CalculateDeadline < Helper
      def initialize(data = {})
        @show_request = data[:show_request]

        @service_codes = data[:service_codes]
        @source_zip_code = data[:source_zip_code]
        @target_zip_code = data[:target_zip_code]
        @reference_date = data[:reference_date]
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
              xml['ns1'].send(@method) do
                xml.nCdServico array_to_string_comma(@service_codes)
                xml.sCepOrigem @source_zip_code
                xml.sCepDestino @target_zip_code
                if @method != 'CalcPrazo'
                  xml.sDtCalculo date_to_string(@reference_date)
                end
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response["#{@method_snake}_response".to_sym]["#{@method_snake}_result".to_sym]

        services = response[:servicos][:c_servico]
        services = [services] if services.is_a?(Hash)

        { services: services.map { |s| format_service(s) } }
      end

      def format_service(service)
        if [0, 10, 11].include?(service[:erro].to_i)
          {
            code: service[:codigo],
            delivery_at_home: string_to_bool(service[:entrega_domiciliar]),
            delivery_on_saturdays: string_to_bool(service[:entrega_sabado]),
            note: service[:obs_fim],
            deadline: {
              days: service[:prazo_entrega].to_i,
              date: string_to_date(service[:data_max_entrega])
            }
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
