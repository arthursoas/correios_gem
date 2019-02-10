require 'savon'

module Correios
  module SRO
    class Client
      def client
        Savon.client(
          wsdl: wsdl,
          ssl_verify_mode: :none
        )
      end

      private

      def wsdl
        'https://webservice.correios.com.br/service/rastro/Rastro.wsdl'
      end

      def test_env?
        (defined?(Rails) && ENV['RAILS_ENV'].in?(%w[test development]) ||
                            ENV['GEM_ENV'].in?(%w[test development]))
      end
    end
  end
end
