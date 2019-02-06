require 'date'

module Correios
  module Pricefier
    class Helper
      def namespaces
        {
          'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope',
          'xmlns:ns1' => 'http://tempuri.org/'
        }
      end

      def convert_string_to_date(date)
        Date.strptime(date, '%d/%m/%Y')
      end

      def convert_string_to_bool(string)
        string == 'S'
      end

      def format_service_codes(services)
        services_string = ''
        services.each do |service|
          services_string += "#{service},"
        end
        services_string
      end
    end
  end
end
