## Solicitar Tickets de Entrega

Documentação dos Correios: `Reserva de Faixa de Numeração de e-Ticket (Range)`

Fornece números de ticket de logística reversa sem o dígito verificador.

____

### Autenticação
Necessário informar:
* `administrative_code`
* `cws_user`
* `cws_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::ReverseLogistics.request_ticket_numbers({
  ticket_type: :pickup,
  service: :pac,
  amount: 4
})
```
* O campo `ticket_type` deve ser preenchido conforme Anexo 1.
* O campo `service` pode ser preenchido conforme Anexo 2.

### Saída

```ruby
{
  :ticket_numbers => [
    '19484776',
    '19484777',
    '19484778',
    '19484779'
  ]
}
```

### Anexos

__Anexo 1:__
Opções de tipo de tickets:
* `:authorization` (Autorização de Postagem)
* `:pickup` (Coleta Residencial)

__Anexo 2:__
Opções de serviços:
* `:pac`
* `:sedex`
* `:e_sedex`
* Neste caso, é permitido mandar texto livre caso o serviço não esteja listado.
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
