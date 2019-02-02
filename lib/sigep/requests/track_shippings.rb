require 'nokogiri'
require 'active_support/core_ext/hash'

require_relative '../client'
require_relative '../helper'
require_relative '../../correios_exception.rb'

module Correios
  module Sigep
    class TrackShippings < CorreiosException
      HELPER = Helper.new
      CLIENT = Client.new

      def initialize(data = {})
        @credentials = Correios.credentials

        @show_request = data[:show_request]
        @label_numbers = data[:label_numbers]
        @query_type = data[:query_type]
        @result_type = data[:result_type]
        super()
      end

      def request
        puts xml if @show_request == true
        begin
          format_response(CLIENT.client.call(:consulta_sro,
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
              xml['ns1'].consultaSRO do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil

                @label_numbers.each do |label_number|
                  xml.listaObjetos label_number
                end
                xml.tipoConsulta query_type(@query_type)
                xml.tipoResultado result_type(@result_type)
                xml.usuarioSro @credentials.sro_user
                xml.senhaSro @credentials.sro_password

                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml
      end

      def format_response(response)
        response = response[:consulta_sro_response][:return]
        response = Hash.from_xml(response)

        objects = response['rastro']['objeto']
        objects = [objects] if objects.is_a?(Hash)

        formatted_objects = []
        objects.each do |object|
          formatted_objects << format_object(object)
        end

        { tracking: formatted_objects }
      end

      def format_object(object)
        events = object['evento']
        events = [events] if events.is_a?(Hash)

        formatted_events = []
        events.each do |event|
          formatted_events << format_event(event)
        end

        {
          label: {
            number: object['numero'],
            initials: object['sigla'],
            name: object['nome'],
            category: object['categoria']
          },
          events: formatted_events
        }
      end

      def format_event(event)
        {
          movement: HELPER.tracking_event_status(event),
          type: event['tipo'],
          status: event['status'],
          time: HELPER.convert_string_to_date(event['data'], event['hora']),
          description: event['descricao'],
          detail: event['detalhe'],
          city: event['cidade'],
          state: event['uf'],
          destination: format_destination(event['destino']),
          site: {
            description: event['local'],
            code: event['codigo']
          }
        }
      end

      def format_destination(destination)
        return nil if destination.nil?
        {
          city: destination['cidade'],
          neighborhood: destination['bairro'],
          state: destination['uf'],
          site: {
            description: destination['local'],
            code: destination['codigo']
          }
        }
      end

      def query_type(type)
        case type
        when :list
          'L'
        when :range
          'F'
        end
      end

      def result_type(type)
        case type
        when :last_event
          'U'
        when :all_events
          'T'
        end
      end
    end
  end
end
