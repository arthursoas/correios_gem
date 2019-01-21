require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class CreateShippings < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @data = data
        @shippings = data[:shippings]
        @request_number = data[:request_number]
        super()
      end

      def request
        begin
          format_response(CLIENT.client.call(:fecha_plp_varios_servicos,
                                             soap_action: '',
                                             xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          generate_exception(error)
        end
      end

      private

      def format_response(response)
        response = response[:fecha_plp_varios_servicos_response][:return]

        { request_id: response }
      end

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].fechaPlpVariosServicos do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.xml HELPER.shippings_xml(@data)
                xml.idPlpCliente @request_number
                xml.cartaoPostagem @credentials.card
                @shippings.each do |shipping|
                  xml.listaEtiquetas HELPER.label_without_digit_checker(
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
    end
  end
end
