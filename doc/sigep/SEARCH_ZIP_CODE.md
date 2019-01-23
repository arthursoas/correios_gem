## Buscar CEP

Documentação dos Correios: `Consulta Endereço via CEP`

Dado um CEP válido, retorna um objeto com os dados a ele associado, o que pode incluir: Estado, Cidade, Bairro, Logradouro e Complemento.

---

### Autenticação
Nenhuma credencial necessária.

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.search_zip_code({
  zip_code: '32145000'
})
```
* O campo `zip_code` pode ser enviado com ou sem a máscara (32145-000 ou 32145000).

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
* O campo `state` é retornado em formato de sigla (ex: AM, MG, RS).

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
