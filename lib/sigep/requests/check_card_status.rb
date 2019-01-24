require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class CheckCardStatus < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:get_status_cartao_postagem,
                                             soap_action: '',
                                             xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          generate_exception(error)
        end
      end

      private

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].getStatusCartaoPostagem do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.numeroCartaoPostagem @credentials.card
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:get_status_cartao_postagem_response][:return]

        { status: convert_status_to_symbol(response) }
      end

      def convert_status_to_symbol(status)
        case status
        when 'Normal'
          :ok
        when 'Cancelado'
          :canceled
        end
      end
    end
  end
end
