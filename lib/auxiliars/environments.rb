module Correios
  class Environment
    attr_accessor :env

    def initialize
      self.sigep_user = :development
    end
  end
  module Pricefier
    def self.client
      base_client(wsdl: wsdl)
    end

    def self.namespaces
      {
        'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope',
        'xmlns:ns1' => 'http://tempuri.org/'
      }
    end

    def self.wsdl
      'http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx?wsdl'
    end
  end

  module ReverseLogistics
    def self.client
      base_client(wsdl: wsdl,
                  basic_auth: [
                    Correios.credentials.reverse_logistics_user || 'user',
                    Correios.credentials.reverse_logistics_password || 'pass'
                  ])
    end

    def self.namespaces
      {
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://service.logisticareversa.correios.com.br/'
      }
    end

    def self.wsdl
      if production_env?
        'https://cws.correios.com.br/logisticaReversaWS/logisticaReversaService/logisticaReversaWS?wsdl'
      else
        'https://apphom.correios.com.br/logisticaReversaWS/logisticaReversaService/logisticaReversaWS?wsdl'
      end
    end
  end

  module Sigep
    def self.client
      base_client(wsdl: wsdl)
    end

    def self.namespaces
      {
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
      }
    end

    def self.wsdl
      if production_env?
        'https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
      else
        'https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
      end
    end
  end

  module SRO
    def self.client
      base_client(wsdl: wsdl)
    end

    def self.namespaces
      {
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://resource.webservice.correios.com.br/'
      }
    end

    def self.wsdl
      'https://webservice.correios.com.br/service/rastro/Rastro.wsdl'
    end
  end
end

def base_client(wsdl:, ssl_verify_mode: :none, basic_auth: [])
  Savon.client(wsdl: wsdl,
               basic_auth: basic_auth,
               ssl_verify_mode: ssl_verify_mode)
end

def production_env?
  Correios.env == :production
end
