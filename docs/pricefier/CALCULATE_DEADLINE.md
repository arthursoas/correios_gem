## Calcular Prazo de Entrega

Documentação dos Correios: `CalcPrazo`

Calcula a data máxima de entrega de uma encomenda entre dois CEPs considerando os serviços utilizados.

____

### Autenticação
Nenhuma credencial necessária.

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Pricefier.calculate_deadline({
  service_codes: ['04162','04669'],
  source_zip_code: '32145000',
  target_zip_code: '32140500'
})

```
* O campo `service_codes[i]` deve ser preenchido com os códigos dos serviços conforme método [Buscar Cliente](../sigep/SEARCH_CUSTOMER.md).

### Saída

```ruby
{
  :services => [
    {
      :code => '4162',
      :delivery_at_home => true,
      :delivery_on_saturdays => true,
      :note => 'O CEP de destino está sujeito a condições especiais de entrega  pela  ECT
                e será realizada com o acréscimo de até 7 (sete) dias úteis ao prazo regular.',
      :deadline => {
        :days => 8,
        :date => Mon, 18 Feb 2019 # Campo tipo Date 
      }
    },
    {
      :code => '4669',
      :error => {
        :code => '008',
        :description => 'Serviço indisponível para o trecho informado.''
      }
    }
  ]
}
```
* O campo `services[i].deadline.days` é a quantidade de dias que os Correios terão para entregar a encomenda.
* O campo `services[i].deadline.date` é a data limite que os Correios terão para entregar a encomenda.
---

[Consultar documentação dos Correios](http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx)
