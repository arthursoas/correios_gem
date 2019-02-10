## Listar Serviços STAR

Documentação dos Correios: `ListaServicosSTAR`

Lista os serviços disponíveis para cálculo de preços (frete) e prazos de entrega de encomendas através do STAR.

____

### Autenticação
Nenhuma credencial necessária.

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Pricefier.list_services_star
})

```

### Saída

```ruby
{
  :services => [
    {
      :code => '04081',
      :description => 'SPP A VISTA E A FATURAR',
      :calculate_price => true,
      :calculate_deadline => false
    },
    {
      :code => '04405',
      :description => 'SEDEX 12 SCADA A VISTA',
      :calculate_price => true,
      :calculate_deadline => false
    },
    ...
  ]
}
```
---

[Consultar documentação dos Correios](http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx)
