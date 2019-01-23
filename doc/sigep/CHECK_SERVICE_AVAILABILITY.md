## Verificar Disponibilidade de Serviço

Documentação dos Correios: `Disponibilidade do Serviço entre o CEP da Origem e CEP de Destino`

Verifica a disponibilidade de envios de encomendas utilizando o serviço especificado.

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`
* `administrative_code`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.check_service_availability({
  service_code: '04162',
  source_zip_code: '05311900',
  target_zip_code: '32140500'
})
```
* Os campos `zip_code` podem ser enviados com ou sem a máscara (32140-500 ou 32140500).

### Saída

```ruby
{
  :status => :available,
  :message => 'O CEP de destino está sujeito a condições especiais de entrega  pela
               ECT e será realizada com o acréscimo de até 7 (sete) dias úteis ao
               prazo regular.
}
```
* Os valores possíveis do campo `status` estão no Anexo 1.
* O campo `message` pode vir vazio.

### Anexos

__Anexo 1:__
Opções de status de disponibilidade de serviço:
* `:available`
* `:partially_available`
* `:unavailable`
* `:invalid_zip_code`
* `:incorrect_data`
* `:unauthorized`
* `:error`
---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
