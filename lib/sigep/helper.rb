require 'date'

module Correios
  module Sigep
    class Helper
      def namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
        }
      end

      def shippings_xml(data)
        credentials = Correios.credentials
        sender = data[:sender]
        sender_address = sender[:address]
        shippings = data[:shippings]

        Nokogiri::XML::Builder.new(encoding: 'ISO-8859-1') do |xml|
          xml.correioslog do
            xml.tipo_arquivo 'Postagem'
            xml.versao_arquivo '2.3'
            xml.plp do
              xml.id_plp
              xml.valor_global
              xml.mcu_unidade_postagem
              xml.nome_unidade_postagem
              xml.cartao_postagem credentials.card
            end
            xml.remetente do
              xml.numero_contrato credentials.contract
              xml.numero_diretoria sender[:board_id]
              xml.codigo_administrativo credentials.administrative_code
              xml.nome_remetente sender[:name]
              xml.logradouro_remetente sender_address[:street]
              xml.numero_remetente sender_address[:number]
              xml.complemento_remetente sender_address[:additional]
              xml.bairro_remetente sender_address[:neighborhood]
              xml.cep_remetente sender_address[:zip_code]
              xml.cidade_remetente sender_address[:city]
              xml.uf_remetente sender_address[:state]
              xml.telefone_remetente sender[:phone]
              xml.fax_remetente sender[:fax]
              xml.email_remetente sender[:email]
            end
            xml.forma_pagamento payment_method(data[:payment_method])
            shippings.each do |shipping|
              receiver = shipping[:receiver]
              receiver_address = receiver[:address]
              object = shipping[:object]
              invoice = shipping[:invoice] || {}
              additional_services = shipping[:additional_services] || []
              notes = shipping[:notes] || []

              xml.objeto_postal do
                xml.numero_etiqueta shipping[:label_number]
                xml.codigo_objeto_cliente
                xml.codigo_servico_postagem shipping[:service_code]
                xml.cubagem '0,00'
                xml.peso object[:weight]
                xml.rt1 notes[0]
                xml.rt2 notes[1]
                xml.destinatario do
                  xml.nome_destinatario receiver[:name]
                  xml.telefone_destinatario receiver[:phone]
                  xml.celular_destinatario receiver[:cellphone]
                  xml.email_destinatario receiver[:email]
                  xml.logradouro_destinatario receiver_address[:street]
                  xml.complemento_destinatario receiver_address[:additional]
                  xml.numero_end_destinatario receiver_address[:number]
                end
                xml.nacional do
                  xml.bairro_destinatario receiver_address[:neighborhood]
                  xml.cidade_destinatario receiver_address[:city]
                  xml.uf_destinatario receiver_address[:state]
                  xml.cep_destinatario receiver_address[:zip_code]
                  xml.codigo_usuario_postal
                  xml.centro_custo_cliente shipping[:cost_center]
                  xml.numero_nota_fiscal invoice[:number]
                  xml.serie_nota_fiscal invoice[:serie]
                  xml.natureza_nota_fiscal invoice[:kind]
                  xml.descricao_objeto shipping[:description]
                  xml.valor_a_cobrar convert_decimal_to_string(
                    shipping[:additional_value]
                  )
                end
                xml.servico_adicional do
                  additional_services.each do |additional_service|
                    xml.codigo_servico_adicional additional_service
                  end
                  xml.valor_declarado shipping[:declared_value]
                end
                xml.dimensao_objeto do
                  xml.tipo_objeto object_type(object[:type])
                  xml.dimensao_altura object[:height] || 0
                  xml.dimensao_largura object[:width] || 0
                  xml.dimensao_comprimento object[:length] || 0
                  xml.dimensao_diametro object[:diameter] || 0
                end
                xml.data_postagem_sara
                xml.status_processamento 0
                xml.numero_comprovante_postagem
                xml.valor_cobrado
              end
            end
          end
        end.to_xml.encode(Encoding::UTF_8)
      end

      def label_without_digit_checker(label_number)
        label_number.slice!(10)
        label_number
      end

      def convert_string_to_bool(string)
        string.strip == 'S'
      end

      def convert_string_to_date(date, time)
        DateTime.strptime("#{date} #{time}", '%d/%m/%Y %H:%M')
      end

      private

      def convert_decimal_to_string(decimal)
        return nil if decimal.nil?

        decimal.to_s.tr('.', ',')
      end

      def object_type(type)
        case type
        when :letter_envelope
          '001'
        when :box
          '002'
        when :prism
          '002'
        when :cylinder
          '003'
        end
      end

      def payment_method(method)
        case method
        when :postal_vouncher
          1
        when :postal_refound
          2
        when :exchange_contract
          3
        when :credit_card
          4
        when :other
          5
        when :to_bill
          nil
        end
      end
    end
  end
end
