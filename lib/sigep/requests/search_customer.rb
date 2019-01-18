require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class SearchCustomer < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize
        @credentials = Correios.credentials
        super()
      end

      def request
        begin
          format_response(CLIENT.client.call(:busca_cliente,
                                             soap_action: '',
                                             xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          generate_exception(error)
        end
      end

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].buscaCliente do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.idContrato @credentials.contract
                xml.idCartaoPostagem @credentials.card
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:busca_cliente_response][:return]

        contracts = response[:contratos]
        contracts = [contracts] if contracts.is_a?(Hash)

        formatted_contracts = []
        contracts.each do |contract|
          formatted_contracts << format_contract(contract)
        end

        {
          status_code: response[:status_codigo].strip,
          status_description: response[:descricao_status_cliente].strip,
          contracts: formatted_contracts
        }
      end

      def format_contract(contract)
        cards = contract[:cartoes_postagem]
        cards = [cards] if cards.is_a?(Hash)

        formatted_cards = []
        cards.each do |card|
          formatted_cards << format_card(card)
        end

        {
          board_id: contract[:codigo_diretoria].strip,
          board_description: contract[:descricao_diretoria_regional].strip,
          validity_begin: contract[:data_vigencia_inicio],
          validity_end: contract[:data_vigencia_fim],
          cards: formatted_cards
        }
      end

      def format_card(card)
        services = card[:servicos]
        services = [services] if services.is_a?(Hash)

        formatted_services = []
        services.each do |service|
          formatted_services << format_service(service)
        end

        {
          validity_begin: card[:data_vigencia_inicio],
          validity_end: card[:data_vigencia_fim],
          services: formatted_services
        }
      end

      def format_service(service)
        sigep_service = service[:servico_sigep]

        {
          category: sigep_service[:categoria_servico],
          code: service[:codigo].strip,
          description: service[:descricao].strip,
          id: service[:id].strip,
          seal: sigep_service[:chancela][:chancela],
          conditions: {
            dimensions_required: sigep_service[:exige_dimensoes],
            addtional_price_required: sigep_service[:exige_valor_cobrar],
            payment_on_delivery: convert_string_to_bool(sigep_service[:pagamento_entrega]),
            grouped_shipment: convert_string_to_bool(sigep_service[:remessa_agrupada])
          }
        }
      end

      def convert_string_to_bool(string)
        string.strip == 'S'
      end
    end
  end
end
