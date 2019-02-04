## Rastrear Entregas por Data

Documentação dos Correios: `Acompanhar Solicitação de Autorização de Postagem ou Solicitação de Coleta Reversa - Pesquisa Por Data`

Busca o atual status de todas as logísticas reversas que tiveram alguma movimentação na data especificada,
indicando se o objeto já foi coletado ou postado na agência dos Correios, o custo da entrega e o número de etiqueta 
gerado para que o objeto possa ser rastreado via SRO.

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
  type: :authorization,
  date: Date.new(2019, 2, 1)
)
```
* O campo `ticket` deve ser preenchido conforme Anexo 1.
* O campo `date` deve ser preenchido com um objeto do tipo `Date`.

### Saída

```ruby
{
  :type => :authorization,
  :shippings => [
    {
      :ticket_number => '1040902295',
      :code => '3889',
      :events => [
        {
          :status => '57',
          :description => 'Prazo de Utilização Expirado',
          :time => 2019-02-01 03:45:02 -0200,
          :note = >nil
        }
      ],
      :objects => [
        {
          :label_number => nil,
          :id => '600234533',
          :shipping_price => 0.0,
          :last_event => {
            :status => '55',
            :description => 'Aguardando Objeto na Agência',
            :time => 2019-01-01 00:02:01 -0200
          }
        }
      ]
    }
    ...
  ]
}
```
* O campo `shippings[i].code` é definido pelo usuário no método [Criar Entregas](CREATE_SHIPPINGS.md)
* O campo `shippings[i].objects[j].id` é definido pelo usuário no método [Criar Entregas](CREATE_SHIPPINGS.md).
* Os campos `shippings[i].events` e `shippings[i].objects` sempre retornarão um Array.

### Anexos

__Anexo 1:__
Opções de tipo de tickets:
* `:authorization` (Autorização de Postagem)
* `:pickup` (Coleta Residencial)

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
