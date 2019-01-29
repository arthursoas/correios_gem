require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module ReverseLogistics
    class CreateShippings < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @receiver = data[:receiver]
        @service_code = data[:service_code]
        @shippings = data[:shippings]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:solicitar_postagem_reversa,
                                             soap_action: '',
                                             xml: xml).to_hash)
        rescue Savon::SOAPFault => error
          generate_exception(error)
        rescue Savon::HTTPError => error
          if error.http.code == 401
            generate_exception("Unauthorized (#{error.http.code}).")
          end
          generate_exception("Unknown HTTP error (#{error.http.code}).")
        end
      end

      private

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(HELPER.namespaces) do
            xml['soap'].Body do
              xml['ns1'].solicitarPostagemReversa do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codAdministrativo @credentials.administrative_code
                xml.cartao @credentials.card
                xml.codigo_servico @service_code
                xml.destinatario do
                  receiver_address = @receiver[:address]
                  xml.nome @receiver[:name]
                  xml.ddd @receiver[:phone][0, 1]
                  xml.telefone @receiver[:phone][2, @receiver[:phone].lenght - 1]
                  xml.email @receiver[:email]
                  xml.logradouro receiver_address[:street]
                  xml.numero receiver_address[:number]
                  xml.complemento receiver_address[:additional]
                  xml.bairro receiver_address[:neighborhood]
                  xml.cidade receiver_address[:city]
                  xml.uf receiver_address[:state]
                  xml.cep receiver_address[:zip_code]
                  xml.referencia
                end
                @shippings.each do |shipping|
                  goods = shipping[:goods] || []
                  objects = shipping[:objects] || []
                  xml.coletas_solicitadas do
                    xml.tipo HELPER.shipping_type(shipping[:type])
                    xml.id_cliente shipping[:code]
                    xml.valor_declarado shipping[:declared_value]
                    xml.descricao shipping[:description]
                    xml.cklist shipping[:check_list]
                    xml.documento shipping[:document]
                    xml.remetente do
                      sender = shipping[:sender]
                      sender_address = shipping[:sender][:address]
                      xml.nome sender[:name]
                      xml.ddd sender[:phone][0, 1]
                      xml.telefone sender[:phone][2, sender[:phone].lenght - 1]
                      xml.ddd_celular sender[:cellphone][0, 1]
                      xml.celular sender[:cellphone][2, sender[:phone].lenght - 1]
                      xml.email sender[:email]
                      xml.sms HELPER.bool_to_string(sender[:send_sms])
                      xml.identificacao sender[:document]
                      xml.logradouro sender_address[:street]
                      xml.numero sender_address[:number]
                      xml.complemento sender_address[:additional]
                      xml.bairro sender_address[:neighborhood]
                      xml.referencia
                      xml.cidade sender_address[:city]
                      xml.uf sender_address[:state]
                      xml.cep sender_address[:zip_code]
                    end
                    goods.each do |good|
                      xml.produto do
                        xml.codigo good[:code]
                        xml.tipo good[:type]
                        xml.qtd good[:amount]
                      end
                    end
                    xml.numero shipping[:ticket_number]
                    xml.ag HELPER.deadline(shipping[:deadline], shipping[:type])
                    xml.cartao @credentials.card
                    xml.servico_adicional HELPER.additional_services(
                      shipping[:additional_services]
                    )
                    objects.each do |object|
                      xml.obj_col do
                        xml.item 1
                        xml.desc object[:description]
                        xml.entrega object[:number]
                        xml.id object[:id]
                        xml.num
                      end
                    end
                  end
                end

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:solicitar_range_response][:solicitar_range]
        generate_exception(response[:msg_erro]) if response[:cod_erro] != '0'

        initial_number = response[:faixa_inicial].to_i
        final_number = response[:faixa_final].to_i

        ticket_numbers = []
        while initial_number <= final_number do
          ticket_numbers << initial_number.to_s
          initial_number += 1
        end

        { ticket_numbers: ticket_numbers }
      end
    end
  end
end
