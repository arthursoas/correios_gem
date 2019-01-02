require 'savon'

module Correios
  module Sigep
    class Client
      def self.client
        Savon.client(
          wsdl: wsdl,
          ssl_verify_mode: :none
        )
      end

      def self.wsdl
        if test_env?
          'https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
        else
          'https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
        end
      end

      def self.test_env?
        (defined?(Rails) && ENV['RAILS_ENV'].in?(%w[test development]) ||
                            ENV['GEM_ENV'].in?(%w[test development]))
      end
    end
  end
end
