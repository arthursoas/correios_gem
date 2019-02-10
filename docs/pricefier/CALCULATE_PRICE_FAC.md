## Calcular Preço (frete) FAC

Documentação dos Correios: `CalcPrecoFAC`

Calcula o custo de entrega (frete) de uma encomenda do tipo FAC (franqueamento autorizado de cartas).

⚠️ Este método não foi testado pois nenhuma requisição retornou um resultado válido. Caso tenha em mãos os códigos de serviço
aceitos pelos Correios, abra um _issue_ com os códigos que você utilizou.

____

### Autenticação
Nenhuma autenticação necessária

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Pricefier.calculate_price_fac({
  show_request: true,
  service_codes: ['84050','82031'],
  weight: 200,
  reference_date: Date.new(2018, 10, 10)
})
```
* O campo `service_codes[i]` deve ser preenchido com os códigos dos serviços conforme método [Buscar Cliente](../sigep/SEARCH_CUSTOMER.md), [Listar Serviços](LIST_SERVICES.md) ou [Listar Serviços STAR](LIST_SERVICES_STAR.md).

### Saída

```ruby
{
  :services => [
    {
      :code= > '84050',
      :prices => {
        :additional_serivces => {
          :own_hands => 0.o,
          :receipt_notification => 0.0,
          :declared_value => 0.o
        },
        :only_shipping => 9.82,
        :total => 26.94
      }
    },
    {
      :code => '82031',
      :error => {
        :code => '2',
        :description => 'País nao aceita o Serviço'
      }
    }
  ]
}
```
---

[Consultar documentação dos Correios](http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx)
