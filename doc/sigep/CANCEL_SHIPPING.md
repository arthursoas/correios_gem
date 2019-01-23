## Cancelar Entrega

Documentação dos Correios: `Solicitação de Suspensão de Entrega de Encomenda ao Destinatário`

Cancela o envio de uma encomenda ao destinatário após postagem na agência dos Correios. A encomenda será devolvida
ao endereço do remetente utilizado na criação da entrega.

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.cancel_shipping({
  label_number: '04162',
  request_id: '1001000'
})
```
* O campo `request_id` é o valor retornado ao criar uma entrega (ver [Criar Entregas](CREATE_SHIPPINGS.pdf)).

### Saída

```ruby
{
  :status => :ok
}
```
* O campo `status` sempre retornará `:ok`, caso contrário será gerada uma exceção.
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
