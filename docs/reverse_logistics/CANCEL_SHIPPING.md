## Cancelar Entrega

Documentação dos Correios: `Cancelamento da Autorização de Postagem ou da Solicitação de Coleta Reversa`

Cancela uma entrega reversa, impedindindo que o cliente deixe o objeto em uma agência dos Correios, ou que o carteiro 
recolha o objeto.

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
Correios::ReverseLogistics.cancel_shipping({
  ticket_number: '19484776',
  ticket_type: :authorization
})
```
* O campo `ticket_number` deve ser preenchido com o dígito verificador.
* O campo `ticket_type` deve ser preenchido conforme Anexo 1.

### Saída

```ruby
{
  :ticket_number => '19484776',
  :status => 'Desistência do Cliente ECT'
}

```

### Anexos

__Anexo 1:__
Opções de tipo de tickets:
* `:authorization` (Autorização de Postagem)
* `:pickup` (Coleta Residencial)

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
