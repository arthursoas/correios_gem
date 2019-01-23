## Rastrear Entregas

Rastreia movimentações ponta a ponta das encomendas especificiadas.

____

### Autenticação
Necessário informar:
* `sro_user`
* `sro_password`

⚠️ __Atenção__: Caso não tenha tais credenciais em mãos, você pode utilizar as de teste
(ver [Autenticação](../../README.md#Autenticação)) que também funcionam em produção.

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.track_shippings({
  label_numbers: [
    'PS746686536BR',
    'PS760237272BR'
  ],
  query_type: :list,
  result_type: :all_events
})
```
* Os valores possíveis do campo `query_type` estão no Anexo 1.
* Os valores possíveis do campo `result_type` estão no Anexo 2.

### Saída

```ruby
{
  :tracking => [
    {
      :label => {
        :number => 'PS746686536BR',
        :initials => 'PS',
        :name => 'ETIQUETA LÓGICA PAC',
        :category => 'ENCOMENDA PAC''
      },
      :events => [
        {
          :type => 'OEC',
          :status => '01',
          :time => Mon, 03 Dec 2018 10:24:00 +0000,
          :description => 'Objeto saiu para entrega ao destinatário',
          :detail => nil,
          :city => 'Contagem',
          :state => 'MG',
          :destination => nil,
          :site => {
            :description => 'CDD NOVO PROGRESSO',
            :code => '32110970'
          }
        },
        {
          :type => 'DO',
          :status => '01',
          :time => Sat, 01 Dec 2018 21:59:00 +0000,
          :description => 'Objeto encaminhado',
          :detail => nil,
          :city => 'BELO HORIZONTE',
          :state => 'MG',
          :destination => {
            :city => 'Contagem',
            :neighborhood => 'Ressaca',
            :state => 'MG',
            :site => {
              :description => 'CDD NOVO PROGRESSO',
              :code => '32110970'
            }
          },
          :site => {
            :description => 'CTCE BELO HORIZONTE',
            :code => '31255973'
          }
        }
        ...
      ]
    }
    ...
  ]
}
```
* Os valores possíveis do campo `status` estão no Anexo 1.

### Anexos

__Anexo 1:__
Opções de status de tipo de solicitação:
* `:list`
* `:range`

__Anexo 2:__
Opções de status de tipo de resultado:
* `:last_event`
* `:all_events`
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
