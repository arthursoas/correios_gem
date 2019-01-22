## Calcular Dígito Verificador de Números de Etiqueta

Documentação dos Correios: `Dígito Verificador de Número da Etiqueta de Postagem`

Calcula os dígitos verificadores de números de etiquetas dos Correios.

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.calculate_label_number_check_digit({
  label_numbers: [
    'SZ46020941 BR',
    'SZ46020942 BR',
    'SZ46020943 BR
  ]
})
```
* Os campos `label_number[i]` devem ser preenchidos no formato retornado pelo método [Solicitar Números de Etiqueta](REQUEST_LABEL_NUMBERS.pdf).

### Saída

```ruby
{
  :digits checkers => ['5', '9', '2']
}
```

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
