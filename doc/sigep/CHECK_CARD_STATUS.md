## Verificar Status do Cartão de Postagem

Documentação dos Correios: `Situação do Cartão de Postagem`

Verifica o status do cartão de postagem, como ok ou cancelado.

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`
* `card`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.check_card_status
```

### Saída

```ruby
{
  :status => :ok
}
```
* Os valores possíveis do campo `status` estão no Anexo 1.

### Anexos

__Anexo 1:__
Opções de status de disponibilidade de serviço:
* `:ok`
* `:canceled`
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
