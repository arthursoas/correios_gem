require 'savon'
require 'nokogiri'

require_relative 'params/params'

module Correios
  class CorreiosException < StandardError; end
  module Sigep
    class QueryZipCode
      def initialize(data = {})
        @zip_code = data[:zip_code]
        super()
      end

      def request
        client = Savon.client(
          wsdl: Params.wsdl,
          ssl_verify_mode: :none
        )
        begin
          client.call(
            :consulta_cep,
            soap_action: '',
            xml: xml
          ).to_hash[:consulta_cep_response][:return]
        rescue Savon::SOAPFault => error
          raise CorreiosException, error
        end
      end

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(Params.namespaces) do
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
    end
  end
end
