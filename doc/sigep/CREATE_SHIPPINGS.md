## Criar Entregas

Documentação dos Correios: `Fechamento de Pré-lista de Postagem de Objetos`

Cria uma lista de entregas (postagens) futuras. As entregas só são consolidadas ao despachar os objetos em uma agência dos
Correios. 

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`
* `administrative_code`
* `contract`
* `card`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.create_shippings({
  request_number: 000001,                     #opcional
  payment_method: 5,                          #opcional
  cost_center: 'Comercial',                   #opcional
  description: 'Peças automotivas',
  declared_value: 352.50,                     #opcional
  additional_value: 10.0,                     #opcional
  sender: {
    board_id: '10',
    name: 'Empresa XPTO',
    phone: '3125522552',
    fax: '3125522552',                        #opcional
    email: 'contato@xpto.com.br',
    address: {
      zip_code: '35690000',
      state: 'MG',
      city: 'Florestal',
      neighborhood: 'Jabuticabeiras',
      street: 'Rua General Souza de Melo',
      number: 123,
      additional: '3o Andar'                  #opcional
    }
  },
  shippings: [
    {
      label_number: 'SZ460209415BR',
      service_code: '04162',
      notes: [                                #opcional
        'Frágil',
        'Conteúdo cortante'
      ],
      receiver: {
        name: 'José Maria Trindade',
        phone: '1138833883',                  #opcional
        cellphone: '11997799779',
        email: 'jose.maria@gmail.com',
        address: {
          zip_code: '69350000',
          state: 'RR',
          city: 'Alto Alegre',
          neighborhood: 'Santo Antonio',
          street: 'Rua Machado',
          number: 200,
          additional: 'B'                     #opcional
        }
      },
      invoice: {                              #opcional
        number: '000120',
        serie: '1',
        kind: 'venda'
      },
      additional_services: [                   #opcional
        '001',
        '049'
      ],
      object: {
        type: :box,
        height: 11.2,
        width: 23,
        length: 12.1,
        diameter: 0
      }
    }
  ]
})
```
* O campo `request_number` deve ser único e definido por você (quando preenchido).
* O campo `payment_method` deve ser preenchido conforme Anexo 1.
* O campo `board_id` é o código da diretoria do seu contrato (ver [Buscar Cliente](SEARCH_CUSTOMER.md)). 
* O campo `label_number` deve ser enviado com o dígito verificador.
* O campo `notes` é um Array que pode receber até duas strings de texto livre.
* O Campo `additional_services` deve ser preenchido com o código dos serviços (ver [Buscar Serviços Adicionais Disponíveis](SEARCH_AVAILABLE_ADDITIONAL_SERVICES.md)).
* O campo `object.type` deve ser preenchido conforme Anexo 2.
* Telefones e CEPs devem ser enviados sem formatação.

### Saída

```ruby
{
  :request_id => '101001'
}
```

### Anexos

__Anexo 1__
Opções de formas de pagamento:

| Código  | Descrição          |
| :------ | :----------------- |
| 1       | Vale Postal        |
| 2       | Reembolso Postal   |
| 3       | Contrato de Câmbio |
| 4       | Cartão de Crédito  |
| 5       | Outros             |
| vazio   | A faturar          |

__Anexo 2__
Opções de tipos de objetos:
* `:letter_envelope`
* `:box`
* `:prism`
* `:cilinder`

⚠️ __Atenção__: Os Correios fazem pouquíssimas validações ao criar uma entrega, o que inclui erros de digitação nos CEPs, endereços e telefones. Verifique a formatação dos dados antes de solicitar a criação das entregas.

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
