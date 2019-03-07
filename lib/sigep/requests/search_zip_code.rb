module Correios
  module Sigep
    class SearchZipCode < Helper
      def initialize(data = {})
        @show_request = data[:show_request]

        @zip_code = data[:zip_code]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(Sigep.client.call(
            :consulta_cep,
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
              xml['ns1'].consultaCEP do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.cep @zip_code

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:consulta_cep_response][:return]
        {
          neighborhood: response[:bairro],
          zip_code: response[:cep],
          city: response[:cidade],
          additional: response[:complemento2],
          street: response[:end],
          state: response[:uf]
        }
      end
    end
  end
end
