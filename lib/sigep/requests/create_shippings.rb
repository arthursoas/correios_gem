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

        @sender = data[:sender]
        @payment_method = data[:payment_method]
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

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].fechaPlpVariosServicos do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.xml shippings_xml
                xml.idPlpCliente @request_number
                xml.cartaoPostagem @credentials.card

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def shippings_xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.correioslog do
            xml.tipo_arquivo 'Postagem'
            xml.versao_arquivo '2.3'
            xml.plp do
              xml.id_plp
              xml.valor_global
              xml.mcu_unidade_postagem
              xml.nome_unidade_postagem
              xml.cartao_postagem @credentials.card
            end
            xml.remetente do
              xml.numero_contrato @credentials.contract
              xml.numero_diretoria @sender[:board_id]
              xml.codigo_administrativo @credentials.administrative_code
              xml.nome_remetente @sender[:name]
              xml.logradouro_remetente @sender[:address][:street]
              xml.numero_remetente @sender[:address][:number]
              xml.complemento_remetente @sender[:address][:additional]
              xml.bairro_remetente @sender[:address][:neighborhood]
              xml.cep_remetente @sender[:address][:zip_code]
              xml.cidade_remetente @sender[:address][:city]
              xml.uf_remetente @sender[:address][:state]
              xml.telefone_remetente @sender[:phone]
              xml.fax_remetente @sender[:fax]
              xml.email_remetente @sender[:email]
            end
            xml.forma_pagamento @payment_method
            @shippings.each do |shipping|
              receiver = shipping[:receiver]
              object = shipping[:object]

              xml.objeto_postal do
                xml.numero_etiqueta shipping[:label_number]
                xml.codigo_objeto_cliente
                xml.codigo_servico_postagem shipping[:service_code]
                xml.cubagem '0,00'
                xml.peso shipping[:weight]
                xml.rt1 shipping[:note]
                xml.rt2
                xml.destinatario do
                  xml.nome_destinatario receiver[:name]
                  xml.telefone_destinatario receiver[:phone]
                  xml.celular_destinatario receiver[:cellphone]
                  xml.email_destinatario receiver[:email]
                  xml.logradouro_destinatario receiver[:address][:street]
                  xml.complemento_destinatario receiver[:address][:additional]
                  xml.numero_end_destinatario receiver[:address][:number]
                end
                xml.nacional do
                  xml.bairro_destinatario receiver[:address][:neighborhood]
                  xml.cidade_destinatario receiver[:address][:city]
                  xml.uf_destinatario receiver[:address][:state]
                  xml.cep_destinatario receiver[:address][:zip_code]
                  xml.codigo_usuario_postal
                  xml.centro_custo_cliente shipping[:cost_center]
                  xml.numero_nota_fiscal shipping[:invoice][:number]
                  xml.serie_nota_fiscal shipping[:invoice][:serie]
                  xml.natureza_nota_fiscal shipping[:invoice][:kind]
                  xml.descricao_objeto shipping[:description]
                  xml.valor_a_cobrar convert_decimal_to_string(shipping[:additional_price])
                end
                xml.servico_adicional do
                  shipping[:additional_services].each do |additional_service|
                    xml.codigo_servico_adicional additional_service
                  end
                  xml.valor_declarado shipping[:declared_value]
                end
                xml.dimensao_objeto do
                  xml.tipo_objeto object_type(object[:type])
                end
              end
            end
          end
        end
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

      def convert_decimal_to_string(decimal)
        decimal.to_s.tr('.', ',')
      end

      def object_type(type)
        case type
        when :box
          '002'
        when :cilinder
          '001'
      end
    end
  end
end
