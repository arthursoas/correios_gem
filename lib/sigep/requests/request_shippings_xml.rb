module Correios
  module Sigep
    class RequestShippingsXML < Helper
      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @request_id = data[:request_id]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(Sigep.client.call(
            :solicita_xml_plp,
            soap_action: '',
            xml: xml
          ).to_hash)
        rescue Savon::SOAPFault => error
          generate_soap_fault_exception(error)
        rescue Savon::HTTPError => error
          generate_http_exception(error.http.code)
        end
      end

      private

      def xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope(Sigep.namespaces) do
            xml['soap'].Body do
              xml['ns1'].solicitaXmlPlp do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.idPlpMaster @request_id
                xml.usuario @credentials.sigep_user
                xml.senha @credentials.sigep_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:solicita_xml_plp_response][:return]
        response = Hash.from_xml(response)

        request = response['correioslog']['plp']
        sender = response['correioslog']['remetente']

        shippings = response['correioslog']['objeto_postal']
        shippings = [shippings] if shippings.is_a?(Hash)

        {
          request_id: request['id_plp'],
          card: request['cartao_postagem'],
          global_value: request['valor_global'].to_f,
          payment_method: inverse_payment_method(
            response['correioslog']['forma_pagamento']
          ),
          shipping_site: {
            name: request['nome_unidade_postagem'],
            code: request['mcu_unidade_postagem']
          },
          sender: format_sender(sender),
          shippings: shippings.map {|s| format_shipping(s)}
        }
      end

      def format_sender(sender)
        {
          contract: sender['numero_contrato'],
          board_id: sender['numero_diretoria'],
          administrative_code: sender['codigo_administrativo'],
          name: sender['nome_remetente'],
          phone: sender['telefone_remetente'],
          fax: sender['fax_remetente'],
          email: sender['email_remetente'],
          address: {
            zip_code: sender['cep_remetente'],
            state: sender['uf_remetente'],
            city: sender['cidade_remetente'],
            neighborhood: sender['bairro_remetente'],
            street: sender['logradouro_remetente'],
            number: sender['numero_remetente'],
            additional: sender['complemento_remetente']
          }
        }
      end

      def format_shipping(shipping)
        additional_services = shipping['servico_adicional']['codigo_servico_adicional']
        additional_services = [additional_services] if additional_services.is_a?(String)

        {
          label_number: shipping['numero_etiqueta'],
          service_code: shipping['codigo_servico_postagem'],
          cost_center: shipping['nacional']['centro_custo_cliente'],
          description: shipping['nacional']['descricao_objeto'],
          declared_value: shipping['servico_adicional']['valor_declarado'],
          value: shipping['valor_cobrado'].to_f,
          proof_number: shipping['numero_comprovante_postagem'],
          cubage: shipping['cubagem'].to_f,
          additional_value: string_to_decimal(
            shipping['nacional']['valor_a_cobrar']
          ),
          additional_services: additional_services,
          notes: format_notes(shipping),
          receiver: format_receiver(
            shipping['destinatario'], shipping['nacional']
          ),
          invoice: format_invoice(shipping['nacional']),
          object: format_object(
            shipping['dimensao_objeto'], shipping['peso']
          )
        }
      end

      def format_notes(shipping)
        notes = []
        notes << shipping['rt1'] if shipping['rt1'].present?
        notes << shipping['rt2'] if shipping['rt2'].present?
        notes
      end

      def format_receiver(receiver, national)
        {
          name: receiver['nome_destinatario'],
          phone: receiver['telefone_destinatario'],
          cellphone: receiver['celular_destinatario'],
          email: receiver['email_destinatario'],
          address: {
            zip_code: national['cep_destinatario'],
            state: national['uf_destinatario'],
            city: national['cidade_destinatario'],
            neighborhood: national['bairro_destinatario'],
            street: receiver['logradouro_destinatario'],
            number: receiver['numero_end_destinatario'],
            additional: receiver['complemento_destinatario']
          }
        }
      end

      def format_invoice(national)
        {
          number: national['numero_nota_fiscal'],
          serie: national['serie_nota_fiscal'],
          kind: national['natureza_nota_fiscal'],
          value: national['valor_nota_fiscal']
        }
      end

      def format_object(object, weight)
        {
          type: inverse_object_type(object['tipo_objeto']),
          height: object['dimensao_altura'].to_f,
          width: object['dimensao_largura'].to_f,
          length: object['dimensao_comprimento'].to_f,
          diameter: object['dimensao_diametro'].to_f,
          weight: weight.to_f
        }
      end
    end
  end
end
