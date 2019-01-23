require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class RequestLabelNumbers < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @amount = data[:amount]
        @service_id = data[:service_id]
        super()
      end

      def request
        begin
          format_response(CLIENT.client.call(:solicita_etiquetas,
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
              xml['ns1'].solicitaEtiquetas do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.tipoDestinatario 'C'
                xml.idServico @service_id
                xml.qtdEtiquetas @amount
                xml.identificador @credentials.cnpj
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:solicita_etiquetas_response][:return]
        response = response.split(',')

        initial_number = response[0].dup.delete('^0-9').to_i
        final_number = response[1].dup.delete('^0-9').to_i

        label_numbers = []
        while initial_number <= final_number do
          letters = response[0].dup.delete('0-9')
          label_numbers << letters.insert(2, "#{initial_number}")
          initial_number += 1
        end

        { label_numbers: label_numbers }
      end
    end
  end
end
