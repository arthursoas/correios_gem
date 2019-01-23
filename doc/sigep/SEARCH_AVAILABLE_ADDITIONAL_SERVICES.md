## Buscar Serviços Adicionais Disponíveis

Documentação dos Correios: `ANEXO 06 - Código do Serviço Adicional`

Busca todos os serviços adicionais disponíveis, assim como os respectivos códigos para utilização durante a criação das entregas.

---

### Autenticação
Nenhuma credencial necessária.

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.search_available_additional_services
```

### Saída

```ruby
{
  :additional_services => [
    {
      :code => "019",
      :description => "VALOR DECLARADO NACIONAL",
      :initials=> "VD"
    }
  ]
}
```

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
