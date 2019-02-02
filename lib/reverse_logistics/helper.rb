require 'date'

module Correios
  module ReverseLogistics
    class Helper
      def namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://service.logisticareversa.correios.com.br/'
        }
      end

      def bool_to_string(bool)
        'S' if bool
        'N'
      end

      def bool_to_int(bool)
        1 if bool
        0
      end

      def deadline(value, type)
        if type == :authorization
          value if value.is_a?(Numeric)
          Date.today - value
        else
          (Date.today + value).strftime('%d/%m/%Y') if value.is_a?(Numeric)
          value.strftime('%d/%m/%Y')
        end
      end

      def shipping_type(type)
        case type
        when :authorization
          'A'
        when :pickup
          'C'
        end
      end

      def shipping_type_inverse(type)
        case type
        when 'A'
          :authorization
        when 'C'
          :pickup
        end
      end

      def ticket_type(type)
        case type
        when :authorization
          'AP'
        when :pickup
          'LR'
        end
      end

      def additional_services(services)
        nil if services.nil?

        services_string = ''
        services.each do |service|
          services_string += "#{service},"
        end
        services_string
      end

      def convert_string_to_date(date)
        Date.strptime(date, '%d/%m/%Y')
      end
    end
  end
end
