module Correios
  module Sigep
    class Params
      def self.namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
        }
      end

      def self.wsdl
        if true
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
