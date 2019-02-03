require 'savon'

module Correios
  module ReverseLogistics
    class Client
      def client
        credentials = Correios.credentials

        Savon.client(
          wsdl: wsdl,
          basic_auth: [
            credentials.reverse_logistics_user,
            credentials.reverse_logistics_password
          ]
        )
      end

      private

      def wsdl
        if test_env?
          'https://apphom.correios.com.br/logisticaReversaWS/logisticaReversaService/logisticaReversaWS?wsdl'
        else
          'https://cws.correios.com.br/logisticaReversaWS/logisticaReversaService/logisticaReversaWS?wsdl'
        end
      end

      def test_env?
        (defined?(Rails) && ENV['RAILS_ENV'].in?(%w[test development]) ||
                            ENV['GEM_ENV'].in?(%w[test development]))
      end
    end
  end
end
