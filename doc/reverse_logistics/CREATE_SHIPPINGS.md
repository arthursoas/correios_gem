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
      objects: [                                              #opcional
        {
          id: '1200011',
          description: 'Radiador Bosh',
          number: nil
        },
        {
          id: '1200012',
          description: 'Amortecedor Cofap',
          number: nil
        }
      ]
    }
  ]
})
```
* O campo `shippings[i].type` deve ser preenchido conforme Anexo 1.
* O campo `shippings[i].code` é opicional, mas é recomendado preenchê-lo pois será o identificador caso ocorra um erro na
requisição.
* O campo `shippings[i].ticket_number` deve ser enviado com o dígito verificador (quando preenchido)
* O Campo `shippings[i].deadline` deve ser preenchido com a data de limite de postagem / coleta <Date>, ou quantidade 
  de dias contados a partir da data da criação da entrega.
* O campo `shippings[i].goods` deve ser preenchido conforme seção 5.2 na [documentação dos Correios](CORREIOS_DOCUMENT.pdf)
.

‌‌ 
* Telefones e CEPs devem ser enviados sem formatação.
* Podem ser enviados até 50 objetos em `shippings` de uma só vez.

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
* Cada item da lista `objects` na entrada gera um item na saída.
* Caso ocorra um erro em uma das entregas da lista `shippings` será retornado o erro dentro do item da saída. __Ex:__

```ruby
{
  :type => :authorization,
  :code => '120001',
  :error=> 'A solicitação do remetente JOSÉ MARIA TRINDADE já foi processado no dia 03/02/2019
            às 01:40:11. Número do pedido 1040921609'
}
```

### Anexos

__Anexo 1:__
Opções de tipos de entregas:
* `:authorization` (Autorização de Postagem)
* `:pickup` (Coleta Residencial)

📌 __Dica__: Os serviços disponíveis para solicitação de loǵistica reversa sâo:
```ruby
{
  name: 'NOVO PAC REVERSO',
  code: '04677'
},
{
  name: 'NOVO SEDEX REVERSO',
  code: '04170'
}
```

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
