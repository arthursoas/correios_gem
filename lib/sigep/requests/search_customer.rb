module Correios
  module Sigep
    class SearchCustomer < Helper
      def initialize(credentials, data = {})
        @credentials = credentials
        @show_request = data[:show_request]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(Sigep.client.call(
            :busca_cliente,
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
              xml['ns1'].buscaCliente do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.idContrato @credentials[:contract]
                xml.idCartaoPostagem @credentials[:card]
                xml.usuario @credentials[:sigep_user]
                xml.senha @credentials[:sigep_password]

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

        @services = []

        client = {
                  cnpj: response[:cnpj].strip,
                  administrative_code: response[:contratos][:cartoes_postagem][:codigo_administrativo].strip
                }

        contracts.map {|c| format_contract(c)}

        {
          client: client,
          status_code: response[:status_codigo].strip,
          status_description: response[:descricao_status_cliente].strip,
          # contracts: contracts.map {|c| format_contract(c)},
          services: @services
        }
      end

      def format_contract(contract)
        cards = contract[:cartoes_postagem]
        cards = [cards] if cards.is_a?(Hash)

        # {
        #   # board_id: contract[:codigo_diretoria].strip,
        #   # board_description: contract[:descricao_diretoria_regional].strip,
        #   # validity_begin: contract[:data_vigencia_inicio],
        #   # validity_end: contract[:data_vigencia_fim],
        #   cards: cards.map {|c| format_card(c)}
        # }
        cards.map {|c| format_card(c)}
      end

      def format_card(card)
        services = card[:servicos]
        services = [services] if services.is_a?(Hash)
        
        # {
        #   validity_begin: card[:data_vigencia_inicio],
        #   validity_end: card[:data_vigencia_fim],
        #   services: services.map {|s| format_service(s)}
        # }
        services.map {|s| format_service(s)}
      end

      def format_service(service)
        sigep_service = service[:servico_sigep]

        # seal = sigep_service[:chancela] ? sigep_service[:chancela][:chancela] : nil
        @services << {
                      code: service[:codigo].strip,
                      category: sigep_service[:categoria_servico],
                      description: service[:descricao].strip,
                      id: service[:id].strip
                    }

        {
          # category: sigep_service[:categoria_servico],
          # code: service[:codigo].strip,
          # description: service[:descricao].strip,
          # id: service[:id].strip,
        #   seal: seal,
          # conditions: {
          #   dimensions_required: sigep_service[:exige_dimensoes],
          #   addtional_price_required: sigep_service[:exige_valor_cobrar],
          #   payment_on_delivery: string_to_bool(
          #     sigep_service[:pagamento_entrega]
          #   ),
          #   grouped_shipment: string_to_bool(
          #     sigep_service[:remessa_agrupada]
          #   )
          # }
        }
      end
    end
  end
end
