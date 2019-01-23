require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class CancelShipping < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @label_number = data[:label_number]
        @request_id = data[:request_id]
        super()
      end

      def request
        puts xml

        begin
          format_response(CLIENT.client.call(:bloquear_objeto,
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
              xml['ns1'].bloquearObjeto do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.numeroEtiqueta @label_number
                xml.idPlp @request_id
                xml.tipoBloqueio 'FRAUDE_BLOQUEIO'
                xml.acao 'DEVOLVIDO_AO_REMETENTE'
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:bloquear_objeto_response][:return]

        { status: convert_status_to_symbol(response) }
      end

      def convert_status_to_symbol(status)
        case status
        when 'Registro gravado'
          :ok
        end
      end
    end
  end
end
