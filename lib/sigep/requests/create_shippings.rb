require_relative '../auxiliars/shipping_xml'

module Correios
  module Sigep
    class CreateShippings < Helper
      def initialize(data = {})
        @credentials = Correios.credentials
        @show_request = data[:show_request]

        @data = data
        @shippings = data[:shippings]
        @request_number = data[:request_number]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(Sigep.client.call(
            :fecha_plp_varios_servicos,
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
              xml['ns1'].fechaPlpVariosServicos do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.xml Sigep.shipping_xml(@data)
                xml.idPlpCliente @request_number
                xml.cartaoPostagem @credentials.card
                @shippings.each do |shipping|
                  xml.listaEtiquetas remove_label_digit_checker(
                    shipping[:label_number].dup
                  )
                end
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:fecha_plp_varios_servicos_response][:return]

        { request_id: response }
      end
    end
  end
end
