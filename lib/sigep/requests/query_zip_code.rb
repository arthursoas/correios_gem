require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../environment'

module Correios
  class CorreiosException < StandardError; end
  module Sigep
    class QueryZipCode
      def initialize(data = {})
        @zip_code = data[:zip_code]
        super()
      end

      def request
        client = Client.client
        begin
          format_response(client.call(:consulta_cep,
                                      soap_action: '',
                                      xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          raise CorreiosException, error
        end
      end

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(Environment.namespaces) do
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
