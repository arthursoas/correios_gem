## Solicitar Números de Etiqueta

Documentação dos Correios: `Solicitação de Faixa de Etiquetas para Postagem`

Fornece números de etiqueta de postagem sem o dígito verificador.

---

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`
* `cnpj`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.request_label_numbers({
  amount: 3,
  service_id: '124849'
})
```
* O campo `service_id` não é o `code` do serviço, mas sim o `id` (ver [Buscar Cliente](SEARCH_CUSTOMER.md)).

### Saída

```ruby
{
  :label_numbers => [
    "SZ46091722 BR",
    "SZ46091723 BR",
    "SZ46091724 BR"
  ]
}
```
* Os campos `label_numbers[i]` vêm com um espaço em branco que deve ser preenchido com o dígito verificador.

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
