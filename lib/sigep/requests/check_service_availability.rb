module Correios
  module Sigep
    class CheckServiceAvailability < Helper
      def initialize(data = {})
        @credentials = Correios.credentials
        @show_request = data[:show_request]

        @service_code = data[:service_code]
        @source_zip_code = data[:source_zip_code]
        @target_zip_code = data[:target_zip_code]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(Sigep.client.call(
            :verifica_disponibilidade_servico,
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
              xml['ns1'].verificaDisponibilidadeServico do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.numeroServico @service_code
                xml.cepOrigem @source_zip_code
                xml.cepDestino @target_zip_code
                xml.codAdministrativo @credentials.administrative_code
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:verifica_disponibilidade_servico_response][:return]
        response = response.split('#')

        { 
          status: inverse_service_availability(response[0]),
          message: response[1]
        }
      end
    end
  end
end
