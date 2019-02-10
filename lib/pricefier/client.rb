require 'savon'

module Correios
  module Pricefier
    class Client
      def client
        Savon.client(
          wsdl: wsdl,
          ssl_verify_mode: :none
        )
      end

      private

      def wsdl
        'http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx?wsdl'
      end
    end
  end
end
