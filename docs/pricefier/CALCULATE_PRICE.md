## Calcular Preço (frete)

Documentação dos Correios: `CalcPreco`

Calcula o custo de entrega (frete) de uma encomenda entre dois CEPs considerando o serviço utilizado, seriviços adicionais
ecolhidos, dimensões do objeto e descontos de seu contrato com os correios.

____

### Autenticação
* `administrative_code`
* `sigep_password`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Pricefier.calculate_price({
  service_codes: ['04162','04669'],
  source_zip_code: '32145000',
  target_zip_code: '32140530',
  object: {
    type: :box,
    weight: 350,
    length: 16,
    height: 10.5,
    width: 12.2,
    diameter: nil
  },
  own_hands: true,
  receipt_notification: false,
  declared_value: 1050.00
})
```
* O campo `service_codes[i]` deve ser preenchido com os códigos dos serviços conforme método [Buscar Cliente](../sigep/SEARCH_CUSTOMER.md).
* O campo `object.type` deve ser preenchido conforme anexo 1.

‌‌ 
* Medidas devem ser calculadas em cm e gramas.

### Saída

```ruby
{
  :services => [
    {
      :code= > '4162',
      :prices => {
        :additional_serivces => {
          :own_hands => 6.8,
          :receipt_notification => 0.0,
          :declared_value => 10.31
        },
        :only_shipping => 9.82,
        :total => 26.93
      }
    },
    {
      :code => '4669',
      :error => {
        :code => '-888',
        :description => 'Não foi encontrada precificação. ERP-007: CEP de origem nao pode
                         postar para o CEP de destino informado(-1).'
      }
    }
  ]
}
```


### Anexos

__Anexo 1:__
Opções de tipos de objetos:
* `:letter_envelope` (Envelope)
* `:box` (Caixa)
* `:prism` (Prisma)
* `:cilinder` (Cilindro)
---

[Consultar documentação dos Correios](http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx)
