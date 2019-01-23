require 'savon'

module Correios
  module Sigep
    class Client
      def client
        Savon.client(
          wsdl: wsdl,
          ssl_verify_mode: :none
        )
      end

      private

      def wsdl
        if true
          'https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
        else
          'https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
        end
      end

      def test_env?
        (defined?(Rails) && ENV['RAILS_ENV'].in?(%w[test development]) ||
                            ENV['GEM_ENV'].in?(%w[test development]))
      end
    end
  end
end
