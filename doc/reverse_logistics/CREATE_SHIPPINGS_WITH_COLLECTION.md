## Criar Entregas com Coleta Simultânea

Documentação dos Correios: `Solicitação de Logística Reversa Simultânea com Coleta`

Cria uma lista de autorizações de postagem ou coletas reversas que serão realizadas apenas mediante a substituição do
objeto por outro objeto enviado por você através do Sigep. As entregas só são consolidadas ao despachar os objetos em uma agência 
dos Correios.

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
Correios::ReverseLogistics.create_shippings_with_collection({
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
      type: :pickup,
      code: '120002',                                         #opcional
      deadline: 30,                                           #opcional
      declared_value: 345.45,                                 #opcional
      description: 'Peças Automotivas',                       #opcional
      check_list: nil,                                        #opcional
      document: nil,                                          #opcional
      label_number: 'DL619955505BR',                          #opcional
      note: 'Objeto frágil',
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
      ]
    }
  ]
})
```
* O campo `shippings[i].type` deve ser preenchido conforme Anexo 1.
* O campo `shippings[i].code` deve ser único e definido por você (quando preenchido).
* É recomendado preencher o campo `shippings[i].code` pois será o identificador da entrega caso ocorra um erro na
requisição.
* O campo `shippings[i].label_number` deve ser preenchido com o número de etiqueta de uma entrega criada no Sigep (ver [Criar Entregas](../sigep/CREATE_SHIPPINGS.md)).
* O campo `shippings[i].label_number` deve ser enviado com o dígito verificador.
* O Campo `shippings[i].deadline` deve ser preenchido com a data de limite de postagem ou data da coleta <Date>, ou quantidade de dias para a data limite de postagem ou data da coleta contados a partir da data do sistema.
* O campo `shippings[i].sender.document` é o CPF ou CNPJ do remetente.
* O campo `shippings[i].goods` deve ser preenchido conforme seção 5.2 da [documentação dos Correios](CORREIOS_DOCUMENT.pdf)
.

‌‌ 
* Telefones, CEPs e documentos devem ser enviados sem formatação.
* Podem ser enviados até 50 objetos em `shippings` de uma só vez.

### Saída

```ruby
{
  :shippings => [
    { 
      :type => :pickup,
      :code => '120002',
      :ticket_number => '010218909',
      :label_number => 'LE232228320BR',
      :object_id => nil,
      :deadline => Thu, 07 Feb 2019
    }
  ]
}
```
ou
```ruby
{
  :type => :pickup,
  :code => '120002',
  :error => 'NÚMERO DE OBJETO JÁ UTILIZADO (DL619955505BR)'
}
```
* O campo `shippings[i].label_number` é o código de rastreio do objeto a ser devolvido.

### Anexos

__Anexo 1:__
Opções de tipos de entregas:
* `:authorization` (Autorização de Postagem)
* `:pickup` (Coleta Residencial)

__Anexo 2:__ Serviços disponíveis para solicitação de loǵistica reversa:

Serviço            | Código
:----------------- | :-----
NOVO PAC REVERSO   | 04677
NOVO SEDEX REVERSO | 04170

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
