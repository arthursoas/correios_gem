## Rastear Entrega

Documentação dos Correios: `Acompanhar Solicitação de Autorização de Postagem ou Solicitação de Coleta Reversa - Pesquisa Pelo Número da Solicitação`

Busca o atual status de uma logística reversa, indicando se o objeto já foi coletado ou postado na agência dos Correios, 
o custo da entrega e o número de etiqueta gerado para que o objeto possa ser rastreado via SRO.

____

### Autenticação
Necessário informar:
* `administrative_code`
* `reverse_logistics_user`
* `reverse_logistics_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::ReverseLogistics.track_shipping(
  ticket_number: '1040919188',
  type: :authorization,
  result_type: :all_events
)
```
* O campo `ticket_number` deve ser preenchido com o dígito verificador.
* O campo `ticket_type` deve ser preenchido conforme Anexo 1.
* O campo `result_type` deve ser preenchido conforme Anexo 2

### Saída

```ruby
{
  :ticket_number => '1040919188',
  :type => :authorization,
  :code => '120001',
  :events => [
    {
      :status => '55',
      :description => 'Aguardando Objeto na Agência',
      :time => Mon, 01 Oct 2018 14:56:24 +0000,
      :note => nil
    },
    {
      :status => '6',
      :description => 'Coletado',
      :time => Mon, 01 Oct 2018 16:54:24 +0000,
      :note => nil
    }
  ],
  :objects => [
    {
      :label_number => 'DY008316415BR',
      :id => '269',
      :shipping_price => 10.51,
      :last_event => {
        :status => '7',
        :description => 'Entregue',
        :time => Tue, 02 Oct 2018 15:49:18 +0000
      }
    }
  ]
}
```
* O campo `code` é definido pelo usuário no método [Criar Entregas](CREATE_SHIPPINGS.md)
* O campo `objects[i].id` é definido pelo usuário no método [Criar Entregas](CREATE_SHIPPINGS.md).
* Os campos `events` e `objects` sempre retornarão um Array.

### Anexos

__Anexo 1:__
Opções de tipo de tickets:
* `:authorization` (Autorização de Postagem)
* `:pickup` (Coleta Residencial)

__Anexo 2:__
Opções de tipo de resultado:
* `:last_event` (Último Evento)
* `:all_events` (Todos os Eventos)
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
