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
    phone: '3125522552',
    email: 'contato@xpto.com.br',
    address: {
      zip_code: '35690000',
      state: 'MG',
      city: 'Florestal',
      neighborhood: 'Jabuticabeiras',
      street: 'Rua General Souza de Melo',
      number: 123,
      additional: '3o Andar'
    }
  },
  shippings: [
    {
      type: :authorization,
      ticket_number: '1040919188',
      code: '123456',
      deadline: 5,
      declared_value: 345.45,
      description: 'Peças Automotivas',
      receipt_notification: true,
      additional_services: ['49','19'],
      sender: {
        name: 'José Maria Trindade',
        phone: '1138833883',
        cellphone: '11997799779',
        sms: false,
        document: '97946030070',
        email: 'jose.maria@gmail.com',
        address: {
          zip_code: '69350000',
          state: 'RR',
          city: 'Alto Alegre',
          neighborhood: 'Santo Antonio',
          street: 'Rua Machado',
          number: 200,
          additional: 'B'
        }
      },
      goods: [
        {
          code: '116600063',
          type: '0',
          amount: 2
        }
      ],
      objects: [
        {
          id: '123456',
          description: 'Radiador Bosh'
        },
        {
          id: '123458',
          description: 'Vela Bosh'
        }
      ]
    }
  ]
})
```

### Saída

```ruby
{
  :digit_checker => '7',
  :ticket_number => '194847767'
}
```
* O campo `ticket_number` já é preenchido com o dígito verificador.
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
