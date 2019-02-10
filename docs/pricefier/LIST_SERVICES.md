## Listar Serviços

Documentação dos Correios: `ListaServicos`

Lista os serviços disponíveis para cálculo de preços (frete) e prazos de entrega de encomendas.

____

### Autenticação
Nenhuma credencial necessária.

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Pricefier.list_services
})

```

### Saída

```ruby
{
  :services => [
    { 
      :code => '02259',
      :description => 'MALA DIRETA PERFIL EXTERNO',
      :calculate_price => false,
      :calculate_deadline => true
    },
    {
      :code => '02267',
      :description => 'CORREIOS LISTA DISTR URGENTE',
      :calculate_price => false,
      :calculate_deadline => true
    },
    ...
  ]
}
```
---

[Consultar documentação dos Correios](http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx)
