## Solicitar XML de Entregas

Documentação dos Correios: `solicitação de XML da PLP`

Retorna o XML das entregas criadas que já foram postadas nas agências dos Correios, com todos os dados já
validados e corrigidos pelos Correios.

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.request_shippings_xml({
  request_id: '101001'
})
```

### Saída


```ruby
{
  :request_id => '101001',
  :card => '0067599079',
  :global_value => 26.72,
  :payment_method => :to_bill,
  :shipping_site => {
    :name => 'AGF AEROPORTO CONFINS',
    :code => '236042'
  },
  :sender => {
    :contract => '9992157880',
    :board_id => '10',
    :administrative_code => '17000190',
    :name => 'Empresa XPTO',
    :phone => '3125522552',
    :fax => '3125522552',
    :email => 'contato@xpto.com.br',
    :address => {
      :zip_code => '35690000',
      :state => 'MG',
      :city => 'Florestal',
      :neighborhood => 'Jabuticabeiras',
      :street => 'Rua General Souza de Melo',
      :number => '123',
      :additional => '3o Andar'
    }
  },
  :shippings => [
    {
      :label_number => 'SZ460209415BR',
      :service_code => '04162',
      :cost_center => 'Comercial',
      :description => 'Peças automotivas',
      :declared_value => 352.50,
      :value => 26.72,
      :proof_number => '1573446553',
      :cubage => 0.0,
      :additional_value => 10.0,
      :additional_services => ['25', '1', '49'],
      :notes => [
        'Frágil',
        'Conteúdo cortante'
      ],
      :receiver => {
        :name => 'José Maria Trindade',
        :phone => '1138833883',
        :cellphone => '11997799779',
        :email => 'jose.maria@gmail.com',
        :address => {
          :zip_code => '69350000',
          :state => 'RR',
          :city => 'Alto Alegre',
          :neighborhood => 'Santo Antonio',
          :street => 'Rua Machado',
          :number => '200',
          :additional => 'B'
        }
      },
      :invoice => {
        :number => '000120',
        :serie => '1',
        :kind => 'venda',
        :value => 352.5
      },
      :object => {
        :type => :box_prism,
        :height => 11.2,
        :width => 23,
        :length => 12.1,
        :diameter => 0,
        :weight => 350.5
      }
    }
  ]
}
```
* O campo `request_number` deve ser único e definido por você (quando preenchido).
* O campo `payment_method` deve ser preenchido conforme Anexo 1.
* O campo `sender.board_id` é o código da diretoria do seu contrato (ver [Buscar Cliente](SEARCH_CUSTOMER.md)). 
* O campo `shippings[i].label_number` deve ser enviado com o dígito verificador.
* O campo `shippings[i].notes` é um Array que pode receber até duas strings de texto livre.
* O Campo `shippings[i].additional_services` deve ser preenchido com os códigos dos serviços (ver [Buscar Serviços Adicionais Disponíveis](SEARCH_AVAILABLE_ADDITIONAL_SERVICES.md)).
* O campo `shippings[i].object.type` deve ser preenchido conforme Anexo 2.

‌‌ 
* Medidas devem ser calculadas em cm e gramas.
* Telefones e CEPs devem ser enviados sem formatação.
* Podem ser enviados vários objetos em `shippings` de uma só vez.


```ruby
{
  :request_id => '101001'
}
```

### Anexos

__Anexo 1:__
Opções de formas de pagamento:
* `:postal_vouncher` (Vale Postal)
* `:postal_refound` (Reembolso Postal)
* `:exchange_contract` (Contrato de Câmbio)
* `:credit_card` (Cartão de Crédito)
* `:other` (Outros)
* `to_bill` (A faturar)

__Anexo 2:__
Opções de tipos de objetos:
* `:letter_envelope` (Envelope)
* `:box` (Caixa)
* `:prism` (Prisma)
* `:cilinder` (Cilindro)

⚠️ __Atenção__: Os Correios fazem poucas validações ao criar uma entrega, o que inclui erros de digitação nos CEPs, endereços e telefones. Verifique os dados antes de solicitar a criação de uma entrega.

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
