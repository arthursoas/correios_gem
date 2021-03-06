## Buscar Cliente

Documentação dos Correios: `Serviços Disponíveis para o Cartão`

Busca dados de seu contrato com os correios, o que inclui o status atual, vigência e serviços contratados.

____

### Autenticação
Necessário informar:
* `sigep_user`
* `sigep_password`
* `contract`
* `card`

### Exemplo de entrada

```ruby
require 'correios_gem'
...
Correios::Sigep.search_customer
```

### Saída

```ruby
{
  :status_code => '1',
  :status_description => 'Ativo',
  :contracts => [
    {
      :board_id => '10',
      :board_description => 'SE - BRASÍLIA',
      :validity_begin => Wed, 26 Apr 2017 00:00:00 +0000,
      :validity_end => Mon, 31 Dec 2040 00:00:00 +0000,
      :cards => [
        {
          :validity_begin => Mon, 16 Apr 2018 00:00:00 +0000,
          :validity_end => Sat, 09 Sep 2023 00:00:00 +0000,
          :services => [
            {
              :category => 'SERVICO_COM_RESTRICAO',
              :code => '40215',
              :description => 'SEDEX 10',
              :id => '104707',
              :seal => '/9j/4AAQSkZJRgABAQEBLAEsAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBw
              YHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDA
              wMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCADRAVsDASIAAh
              EBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQ
              IDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0...'
              :conditions => {
                :dimensions_required => false,
                :addtional_price_required => false,
                :payment_on_delivery => false,
                :grouped_shipment => false
              }
            }
            ...
          ]
        }
      ]
    }
  ]
}
```
* O campo `seal` é uma imagem PNG em formato base64.
* Os campos `board` são a diretoria do seu contrato.
* Os campos `contratcts`, `cards` e `services` sempre retornarão um Array.

---

[Consultar documentação dos Correios](CORREIOS_DOCUMENT.pdf)
