module Correios
  module Pricefier
    class CalculatePriceDeadline < Helper
      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @service_codes = data[:service_codes]
        @source_zip_code = data[:source_zip_code]
        @target_zip_code = data[:target_zip_code]
        @object = data[:object]
        @own_hands = data[:own_hands]
        @receipt_notification = data[:receipt_notification]
        @declared_value = data[:declared_value]
        @reference_date = data[:reference_date]
        super()
      end

      def request(method)
        @method = method
        @method_snake = method.underscore

        puts xml if @show_request == true
        begin
          format_response(Pricefier.client.call(
            :calc_preco,
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
                xml.nCdEmpresa @credentials.administrative_code
                xml.sDsSenha @credentials.sigep_password
                xml.nCdServico array_to_string_comma(@service_codes)
                xml.sCepOrigem @source_zip_code
                xml.sCepDestino @target_zip_code
                xml.nCdFormato pricefier_object_type(@object[:type])
                xml.nVlPeso @object[:weight].to_f/1000
                xml.nVlComprimento @object[:length] || 0
                xml.nVlAltura @object[:height] || 0
                xml.nVlLargura @object[:width] || 0
                xml.nVlDiametro @object[:diameter] || 0
                xml.sCdMaoPropria bool_to_string(@own_hands)
                xml.sCdAvisoRecebimento bool_to_string(@receipt_notification)
                xml.nVlValorDeclarado @declared_value || 0
                if @method != 'CalcPrecoPrazo'
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

        { services: services.map {|s| format_service(s)} }
      end

      def format_service(service)
        if [0, 10, 11].include?(service[:erro].to_i)
          delivery_on_saturdays = string_to_bool(service[:entrega_sabado])
          {
            code: service[:codigo],
            prices: {
              additional_services: {
                own_hands: string_to_decimal(service[:valor_mao_propria]),
                receipt_notification: string_to_decimal(
                  service[:valor_aviso_recebimento]
                ),
                declared_value: string_to_decimal(service[:valor_valor_declarado])
              },
              only_shipping: string_to_decimal(service[:valor_sem_adicionais]),
              total: string_to_decimal(service[:valor])
            },
            delivery_at_home: string_to_bool(service[:entrega_domiciliar]),
            delivery_on_saturdays: delivery_on_saturdays,
            deadline: {
              days: service[:prazo_entrega].to_i,
              date: 
              if @method == 'CalcPrecoPrazo'
                calculate_shipping_deadline(
                  service[:prazo_entrega].to_i,
                  delivery_on_saturdays
                )
              else
                calculate_shipping_deadline(
                  service[:prazo_entrega].to_i,
                  delivery_on_saturdays,
                  @reference_date
                )
              end
            },
            note: service[:obs_fim]
          }
        else
          {
            code: service[:codigo],
            error: {
              code: service[:erro],
              description: service[:msg_erro]
            }
          }
        end
      end
    end
  end
end
