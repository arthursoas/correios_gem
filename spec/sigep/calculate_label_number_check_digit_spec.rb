require 'spec_helper'
require "savon/mock/spec_helper"

describe Correios::Sigep::CalculateLabelNumberCheckDigit do
  include Savon::SpecHelper

  before do
    Correios.authenticate do |auth|
      auth.sigep_user =                 'sigep'
      auth.sigep_password =             'n5f9t8'
      auth.administrative_code =        '17000190'
      auth.contract =                   '9992157880'
      auth.card =                       '0067599079'
      auth.cnpj =                       '34028316000103'
    end

    savon.mock!
  end

  it 'Valid response' do
    savon.expects(:gera_digito_verificador_etiquetas)
         .with(message: {labels: '1'})
         .returns(Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope({
            'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
            'xmlns:ns2' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
          }) do
            xml['soap'].Body do
              xml['ns2'].geraDigitoVerificadorEtiquetasResponse do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil
  
                xml.return 6
                xml.return 2
  
                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml)

    expect(Correios::Sigep.calculate_label_number_check_digit(label_numbers: ['1','2'])).to be_equal(
      { a: 't' }
    )
  end
end