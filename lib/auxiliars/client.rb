require 'savon'

class PricefierEnvironment
  def client
    Savon.client(wsdl: wsdl, ssl_verify_mode: :none)
  end

  def namespaces
    {
      'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope',
      'xmlns:ns1' => 'http://tempuri.org/'
    }
  end

  def wsdl
    'http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx?wsdl'
  end
end

class SigepEnvironment
  def client
    base_client(nil, :none, wsdl)
  end

  def namespaces
    {
      'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
      'xmlns:ns1' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
    }
  end

  def wsdl
    if test_env?
      'https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
    else
      'https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl'
    end
  end
end

def base_client(basic_auth, ssl_verify_mode, wsdl)
  Savon.client(wsdl: wsdl,
               ssl_verify_mode: ssl_verify_mode,
               basic_auth: basic_auth || [])
end

def test_env?
  (defined?(Rails) && ENV['RAILS_ENV'].in?(%w[test development]) ||
                      ['test','development'].include?(ENV['GEM_ENV']))
end
