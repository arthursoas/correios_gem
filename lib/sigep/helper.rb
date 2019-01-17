module Correios
  module Sigep
    class Helper
      def namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
        }
      end
    end
  end
end
