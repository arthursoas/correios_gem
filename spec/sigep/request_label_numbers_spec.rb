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

  it 'generates numbers for given range' do
    savon.expects(:solicita_etiquetas)
         .returns(Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['soap'].Envelope({
            'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
            'xmlns:ns2' => 'http://cliente.bean.master.sigep.bsb.correios.com.br/'
          }) do
            xml['soap'].Body do
              xml['ns2'].solicitaEtiquetasResponse do
                parent_namespace = xml.parent.namespace
                xml.parent.namespace = nil
  
                xml.return 'OX03815541 BR,OX03815545 BR'
  
                xml.parent.namespace = parent_namespace
              end
            end
          end
        end.doc.root.to_xml)

    result = Correios::Sigep.request_label_numbers(amount: 1, service_id: '999999')
    expect(result[:label_numbers]).to eq([
      "OX03815541 BR",
      "OX03815542 BR",
      "OX03815543 BR",
      "OX03815544 BR",
      "OX03815545 BR"
    ])
  end
end
