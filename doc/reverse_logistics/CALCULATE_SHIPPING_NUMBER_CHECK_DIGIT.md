## Calcular Dígito Verificador de Ticket

Documentação dos Correios: `Cálculo de Dígito Verificador de e-Ticket`

Calcula os dígitos verificadores de números de ticket de logística reversa.

____

### Autenticação
Necessário informar:
* `reverse_logistics_user`
* `reverse_logistics_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::ReverseLogistics.calculate_ticket_number_check_digit({
  ticket_number: '19484776'
})
```

### Saída

```ruby
{
  :digit_checker => '7',
  :ticket_number => '194847767'
}
```
* O campo `ticket_number` já é preenchido com o dígito verificador.
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
