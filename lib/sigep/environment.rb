module Correios
  module Sigep
    class Environment
      def self.namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
        }
      end
    end
  end
end
