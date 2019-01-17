## Buscar CEP

Dado um CEP válido, retorna um objeto com os dados a ele associado, o que pode incluir: Estado, Cidade, Bairro, Logradouro e Complemento.


__Observações__
* Os estados vêm em formato de sigla (ex: AM, MG, RS).
* O CEP pode ser enviado com ou sem a máscara (321450-000 vs 32145000).

### Entrada esperada

```ruby
require 'correios_gem'
...
Correios::Sigep.search_zip_code({
  zip_code: '32145000'
})
```

### Saída

```ruby
{
  :neighborhood => 'Kennedy',
  :zip_code => '32145000',
  :city => 'Contagem',
  :additional => nil,
  :street => 'Avenida das Américas'
  :state => 'MG'
}
```

[Voltar](../../README.md#Utilização)
