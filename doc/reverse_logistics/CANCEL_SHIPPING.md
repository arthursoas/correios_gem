## Cancelar Entrega

Documentação dos Correios: `Cancelamento da Autorização de Postagem ou da Solicitação de Coleta Reversa`

Cancela uma entrega reversa, impedindindo que o cliente deixe o objeto em uma agência dos Correios, ou que o carteiro 
recolha o objeto.

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
Correios::ReverseLogistics.cancle_shipping({
  ticket_number: '19484776',
  ticket_type: :authorization
})
```
* O campo `ticket_number` já é preenchido com o dígito verificador.
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
