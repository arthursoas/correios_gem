## Rastrear Entregas

Rastreia movimentações ponta a ponta das encomendas especificiadas.

____

### Autenticação
Necessário informar:
* `sro_user`
* `sro_password`

⚠️ __Atenção__: Caso nào tenha tais credenciais em mãos, você pode utilizar as de teste
(ver [autenticação](../../README.md#Autenticação)) que também funcionam em produção.

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
