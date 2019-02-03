## Criar Entregas

Documentação dos Correios: `Solicitação de Autorização de Postagem ou Solicitaço de Coleta Reversa`

Cria uma lista de autorizações de postagem ou coletas reversas. As entregas só são consolidadas ao
despachar os objetos em uma agência dos Correios.

____

### Autenticação
Necessário informar:
* `administrative_code`
* `card`
* `reverse_logistics_user`
* `reverse_logistics_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::ReverseLogistics.create_shippings({
  service_code: '04677',
  receiver: {
    name: 'Empresa XPTO',
    phone: '3125522552',                                      #opcional
    email: 'contato@xpto.com.br',                             #opcional
    address: {
      zip_code: '35690000',
      state: 'MG',
      city: 'Florestal',
      neighborhood: 'Jabuticabeiras',                         #opcional
      street: 'Rua General Souza de Melo',
      number: 123,
      additional: '3o Andar'                                  #opcional
    }
  },
  shippings: [
    {
      type: :authorization,
      ticket_number: '1040919188',                            #opcional
      code: '120001',                                         #opcional
      deadline: 5,                                            #opcional
      declared_value: 345.45,                                 #opcional
      description: 'Peças Automotivas',                       #opcional
      receipt_notification: true,
      additional_services: ['49','19'],                       #opcional
      check_list: nil,                                        #opcional
      document: nil,                                          #opcional
      sender: {
        name: 'José Maria Trindade',
        phone: '1138833883',
        cellphone: '11997799779',                             #opcional
        sms: false,
        document: '97946030070',
        email: 'jose.maria@gmail.com',
        address: {
          zip_code: '69350000',
          state: 'RR',
          city: 'Alto Alegre',
          neighborhood: 'Santo Antonio',                      #opcional
          street: 'Rua Machado',
          number: 200,
          additional: 'B'                                     #opcional
        }
      },
      goods: [                                                #opcional
        {
          code: '116600063',
          type: '0',
          amount: 2
        }
      ],
      objects: [
        {
          id: '1200011',
          description: 'Radiador Bosh',
          number: nil                                         #opcional
        },
        {
          id: '1200012',
          description: 'Amortecedor Cofap',
          number: nil                                         #opcional
        }
      ]
    }
  ]
})
```

### Saída

```ruby
{
  :shippings => [
    { 
      :type => :authorization,
      :code => '120001',
      :ticket_number => '1040919195',
      :label_number => nil,
      :object_id => '1200011',
      :deadline => Wed, 13 Feb 2019
    },
    {
      :type => :authorization,
      :code => '120001',
      :ticket_number => '1040919195',
      :label_number=>nil,
      :object_id => '1200012',
      :deadline => Wed, 13 Feb 2019
    }
  ]
}
```
* O campo `ticket_number` já é preenchido com o dígito verificador.
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
