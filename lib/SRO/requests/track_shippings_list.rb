require 'savon'
require 'nokogiri'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module SRO
    class TrackShippingsList < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @label_numbers = data[:label_numbers]
        @query_type = data[:query_type]
        @result_type = data[:result_type]
        @language = data[:language]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:busca_eventos_lista,
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
              xml['ns1'].buscaEventosLista do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                @label_numbers.each do |label_number|
                  xml.objetos label_number
                end
                xml.tipo HELPER.query_type(@query_type)
                xml.resultado HELPER.result_type(@result_type)
                xml.lingua HELPER.language(@language)
                xml.usuario @credentials.sro_user
                xml.senha @credentials.sro_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:busca_eventos_lista_response][:return]
        
        objects = response[:objeto]
        objects = [objects] if objects.is_a?(Hash)
        
        generate_exception(objects.first[:erro]) if objects.first[:numero] == 'Erro'
      
        formatted_objects = []
        objects.each do |object|
          formatted_objects << format_object(object)
        end

        { tracking: formatted_objects }
      end

      def format_object(object)
        if object[:erro].present?
          return { 
            label: {
              number: object[:numero]
            },
            error: object[:erro]
          }
        end

        events = object[:evento]
        events = [events] if events.is_a?(Hash)

        formatted_events = []
        events.each do |event|
          formatted_events << format_event(event)
        end

        {
          label: {
            number: object[:numero],
            initials: object[:sigla],
            name: object[:nome],
            category: object[:categoria]
          },
          events: formatted_events
        }
      end

      def format_event(event)
        {
          movement: HELPER.tracking_event_status(event),
          type: event[:tipo],
          status: event[:status],
          time: HELPER.convert_string_to_date(event[:data], event[:hora]),
          description: event[:descricao],
          detail: event[:detalhe],
          city: event[:cidade],
          state: event[:uf],
          destination: format_destination(event[:destino]),
          site: {
            description: event[:local],
            zip_code: event[:codigo]
          }
        }
      end

      def format_destination(destination)
        return nil if destination.nil?
        {
          city: destination[:cidade],
          neighborhood: destination[:bairro],
          state: destination[:uf],
          site: {
            description: destination[:local],
            zip_code: destination[:codigo]
          }
        }
      end
    end
  end
end
