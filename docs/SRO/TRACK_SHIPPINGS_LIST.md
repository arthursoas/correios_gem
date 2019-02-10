## Rastrear Entregas Lista

Rastreia movimentações ponta a ponta das encomendas especificiadas.

____

### Autenticação
Necessário informar:
* `sro_user`
* `sro_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::SRO.track_shippings_list({
  label_numbers: [
    'PS746686536BR',
    'PS760237272BR'
  ],
  language: :portuguese,
  query_type: :list,
  result_type: :all_events
})
```
* Os valores possíveis do campo `language` estão no Anexo 1.
* Os valores possíveis do campo `query_type` estão no Anexo 2.
* Os valores possíveis do campo `result_type` estão no Anexo 3.

### Saída

```ruby
{
  :tracking => [
    {
      :label => {
        :number => 'PS746686536BR',
        :initials => 'PS',
        :name => 'ETIQUETA LÓGICA PAC',
        :category => 'ENCOMENDA PAC'
      },
      :events => [
        {
          :movement: :delivering,
          :type => 'OEC',
          :status => '01',
          :time => 2018-08-30 15:16:00 -0300,
          :description => 'Objeto saiu para entrega ao destinatário',
          :detail => nil,
          :city => 'Contagem',
          :state => 'MG',
          :site => {
            :description => 'CDD NOVO PROGRESSO',
            :zip_code => '32110970'
          },
          :destination => nil
        },
        {
          :movement: :in_transit,
          :type => 'DO',
          :status => '01',
          :time => 2018-12-01 21:59:00 -0300,
          :description => 'Objeto encaminhado',
          :detail => nil,
          :city => 'BELO HORIZONTE',
          :state => 'MG',
          :site => {
            :description => 'CTCE BELO HORIZONTE',
            :zip_code => '31255973'
          },
          :destination => {
            :city => 'Contagem',
            :neighborhood => 'Ressaca',
            :state => 'MG',
            :site => {
              :description => 'CDD NOVO PROGRESSO',
              :zip_code => '32110970'
            }
          }
        }
        ...
      ]
    }
    ...
  ]
}
```
* Os valores possíveis do campo `tracking[i].events[j].movement` estão no Anexo 4.

### Anexos

__Anexo 1:__
Opções de idioma:
* `:portuguese` (Portugês)
* `:english` (Inglês)

__Anexo 2:__
Opções de tipo de solicitação:
* `:list` (Lista)
* `:range` (Intervalo)

__Anexo 3:__
Opções de tipo de resultado:
* `:last_event` (Último Evento)
* `:all_events` (Todos os Eventos)

__Anexo 4:__
Opções de movimento de evento:
* `:arrested` (Apreendido)
* `:awaiting_pickup` (Aguardando retirada)
* `:damaged` (Danificado)
* `:delivered` (Entregue)
* `:delivering` (Entregando)
* `:in_transit` (Em trânsito)
* `:not_delivered` (Não entregue)
* `:posted` (Postado na agência)
* `:returned` (Devolvido)
* `:returning` (Devolvendo)
* `:stolen_lost` (Roubado / Perdido)
* `:taxing` (Taxação / Alfândega)

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
