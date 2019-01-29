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
    end
  end
end