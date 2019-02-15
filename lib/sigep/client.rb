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

      def namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
        }
      end

      private

      def wsdl
        if test_env?
          'https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
        else
          'https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
        end
      end

      def test_env?
        (defined?(Rails) && ENV['RAILS_ENV'].in?(%w[test development]) ||
                            ['test','development'].include?(ENV['GEM_ENV']))
      end
    end
  end
end
