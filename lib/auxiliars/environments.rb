module Correios
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
                    Correios.credentials.cws_user || 'user',
                    Correios.credentials.cws_password || 'pass'
                  ])
    end

    def self.namespaces
      {
        'xmlns:soap' => DEFAULT_SOAP_NAMESPACE,
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
        'xmlns:soap' => DEFAULT_SOAP_NAMESPACE,
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
        'xmlns:soap' => DEFAULT_SOAP_NAMESPACE,
        'xmlns:ns1' => 'http://resource.webservice.correios.com.br/'
      }
    end

    def self.wsdl
      'https://webservice.correios.com.br/service/rastro/Rastro.wsdl'
    end
  end

  module PostOffice
    def self.client
      base_client(wsdl: wsdl,
                  basic_auth: [
                    Correios.credentials.cws_user || 'user',
                    Correios.credentials.cws_password || 'pass'
                  ])
    end

    def self.namespaces
      {
        'xmlns:soap' => DEFAULT_SOAP_NAMESPACE,
        'xmlns:ns1' => 'http://service.agencia.cws.correios.com.br/'
      }
    end

    def self.wsdl
      if production_env?
        'https://cws.correios.com.br/cws/agenciaService/agenciaWS?wsdl'
      else
        'https://apphom.correios.com.br/cws/agenciaService/agenciaWS?wsdl'
      end
    end
  end
end

DEFAULT_SOAP_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/'.freeze

def base_client(wsdl:, ssl_verify_mode: :none, basic_auth: [])
  Savon.client(wsdl: wsdl,
               basic_auth: basic_auth,
               ssl_verify_mode: ssl_verify_mode)
end

def production_env?
  return false unless defined?(Rails)
  return true if Rails.env.production?

  false
end
