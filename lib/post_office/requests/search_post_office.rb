module Correios
  module PostOffice
    class SearchPostOffice < Helper
      def initialize(data = {})
        @show_request = data[:show_request]

        @code = data[:code]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(PostOffice.client.call(
            :consultar_agencia,
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
          xml['soap'].Envelope(PostOffice.namespaces) do
            xml['soap'].Body do
              xml['ns1'].consultarAgencia do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                xml.codigo @code

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:consultar_agencia_response][:resultado_agencia_detalhe]
        generate_post_office_exception(response)
        post_office = response[:agencia]

        phones = post_office[:telefones]
        phones = [phones] if phones.is_a?(Hash)

        services = post_office[:servicos]
        services = [services] if services.is_a?(Hash)

        puts post_office

        {
          name: post_office[:nome].strip,
          code: post_office[:@codigo].strip,
          cnpj: post_office[:cnpj],
          state_registration: post_office[:inscricao_estadual],
          email: post_office[:email],
          phones: phones.map { |p| "#{p[:ddd].strip}#{p[:numero_telefone].strip}" },
          address: format_address(
            post_office[:endereco], post_office[:localizacao_geografica]
          ),
          opening_time: {
            days: post_office[:dias_funcionamento],
            start: post_office[:horario_funcionamento][:inicio].strip,
            end: post_office[:horario_funcionamento][:fim].strip
          },
          services: services.map { |s| format_service(s) },
          additional_serivces: {
            capitalization_postal_cap: post_office[:posta_cap],
            correios_mobile_phone: post_office[:correios_celular],
            postal_bank: post_office[:atende_como_banco_postal],
            click_and_withdraw: post_office[:clique_e_retire]
          }
        }
      end

      def format_service(service)
        {
          description: service[:descricao],
          code: service[:@codigo]
        }
      end

      def format_address(address, coodinates)
        {
          zip_code: address[:cep_agencia],
          state: address[:uf_agencia],
          city: address[:cidade_agencia],
          neighborhood: address[:bairro_agencia],
          street: address[:logradouro_agencia],
          number: address[:numero_endereco_agencia],
          additional: address[:complemento_endereco_agencia],
          coordinates: {
            latitude: coodinates[:latitude].to_f,
            longitude: coodinates[:longitude].to_f
          }
        }
      end
    end
  end
end
