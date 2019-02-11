# correios_gem

[![Gem Version](https://badge.fury.io/rb/correios_gem.svg)](https://badge.fury.io/rb/correios_gem)

### A correios_gem permite você integrar a sua aplicação Ruby on Rails com as todas APIs dos Correios de maneira simples e rápida.

Através desta biblioteca, é realizada a integração com as quatro APIs dos Carreios, sendo elas:
* __Sigep__: Utilizada para buscar CEPs, solicitar entregas e verificar seu contrato com os correios.
* __Logística Reversa__: Utilizada para devoluções de encomendas através de seu contrato com os correios.
* __Precificador__: Utilizada para calcular preços (frete) e prazos de entregas através de seu contrato com os correios.
* __SRO__: Utilizada para rastrear entregas.

Esqueça requisições SOAP e códigos confusos criados pelos Correios. A correios_gem simplifica toda a comunicação com as APIs dos Correios através de ojetos Ruby e nomenclatura legível para seres humanos.

⚠️ __Atenção__: A correios_gem é uma biblioteca independente que não possui vínculo com os Correios. Para problemas com os Correios, consulte o gerente de seu contrato.

## Utilização

### Autenticação

Para se autenticar nas APIs dos Correios, o código abaixo deve ser inserido no(s) `environments` de sua aplicação com as credenciais de seu contrato com os Correios.

```ruby
# Credenciais de ambiente de testes dos Correios.
# Substitua pelas suas credenciais para utilizar o ambiente de produção dos Correios.

Correios.authenticate do |auth|
  auth.sigep_user =                 'sigep'
  auth.sigep_password =             'n5f9t8'
  auth.administrative_code =        '17000190'
  auth.contract =                   '9992157880'
  auth.card =                       '0067599079'
  auth.cnpj =                       '34028316000103'

  auth.reverse_logistics_user =     'empresacws'
  auth.reverse_logistics_password = '123456'
  
  auth.sro_user =                   'ECT'
  auth.sro_password =               'SRO'
end
```
⚠️ __Atenção__: Não é obrigatório informar todas as credenciais para utilizar a correios_gem. Os métodos que você fará uso podem solicitar apenas parte das credenciais ou nenhuma delas. Verifique na documentação abaixo.

### Métodos

Cada link direciona para a página com a descrição do método, credenciais necessárias para utilização, entrada e saída.

* __Sigep__
  * [Buscar CEP](docs/sigep/SEARCH_ZIP_CODE.md)
  * [Buscar Cliente](docs/sigep/SEARCH_CUSTOMER.md)
  * [Buscar Serviços Adicionais Disponíveis](docs/sigep/SEARCH_AVAILABLE_ADDITIONAL_SERVICES.md)
  * [Calcular Dígito Verificador de Número de Etiqueta](docs/sigep/CALCULATE_LABEL_NUMBER_CHECK_DIGIT.md)
  * [Cancelar Entrega](docs/sigep/CANCEL_SHIPPING.md)
  * [Criar Entregas](docs/sigep/CREATE_SHIPPINGS.md)
  * ~~[Rastrear Entregas](docs/sigep/TRACK_SHIPPING.md)~~
  * [Solicitar Números de Etiqueta](docs/sigep/REQUEST_LABEL_NUMBERS.md)
  * [Solicitar XML de Entregas](docs/sigep/REQUEST_SHIPPINGS_XML.md)
  * [Verificar Disponibilidade de Serviço](docs/sigep/CHECK_SERVICE_AVAILABILITY.md)
  * [Verificar Status do Cartão de Postagem](docs/sigep/CHECK_CARD_STATUS.md)
* __Logística Reversa__
  * [Calcular Dígito Verificador de Ticket](docs/reverse_logistics/CALCULATE_SHIPPING_NUMBER_CHECK_DIGIT.md)
  * [Criar Entregas](docs/reverse_logistics/CREATE_SHIPPINGS.md)
  * [Criar Entregas com Coleta Simultânea](docs/reverse_logistics/CREATE_SHIPPINGS_WITH_COLLECTION.md)
  * [Cancelar Entrega](docs/reverse_logistics/CANCEL_SHIPPING.md)
  * [Rastrear Entrega](docs/reverse_logistics/TRACK_SHIPPING.md)
  * [Rastrear Entregas por Data](docs/reverse_logistics/TRACK_SHIPPINGS_BY_DATE.md)
  * [Solicitar Tickets de Entrega](docs/reverse_logistics/REQUEST_SHIPPING_NUMBERS.md)
* __Precificador__
  * [Calcular Prazo de Entrega](docs/pricefier/CALCULATE_DEADLINE.md)
  * [Calcular Prazo de Entrega com Data](docs/pricefier/CALCULATE_DEADLINE_WITH_DATE.md)
  * [Calcular Prazo de Entrega com Restrições](docs/pricefier/CALCULATE_DEADLINE_WITH_RESTRICTIONS.md)
  * [Calcular Preço (frete)](docs/pricefier/CALCULATE_PRICE.md)
  * [Calcular Preço (frete) com Data](docs/pricefier/CALCULATE_PRICE_WITH_DATE.md)
  * [Calcular Preço (frete) FAC](docs/pricefier/CALCULATE_PRICE_FAC.md)
  * [Calcular Preço (frete) e Prazo de Entrega](docs/pricefier/CALCULATE_PRICE_DEADLINE.md)
  * [Calcular Preço (frete) e Prazo de Entrega com Data](docs/pricefier/CALCULATE_PRICE_DEADLINE_WITH_DATE.md)
  * [Calcular Preço (frete) e Prazo de Entrega com Restrições](docs/pricefier/CALCULATE_PRICE_DEADLINE_WITH_RESTRICTIONS.md)
  * [Listar Serviços](docs/pricefier/LIST_SERVICES.md)
  * [Listar Serviços STAR](docs/pricefier/LIST_SERVICES_STAR.md)
* __SRO__
  * [Rastrear Entregas](docs/SRO/TRACK_SHIPPINGS.md)
  * [Rastrear Entregas Lista](docs/SRO/TRACK_SHIPPINGS_LIST.md)
  
  
### Debug

Todos os métodos aceitam o parâmetro `:show_request`, que, caso seu valor seja `true`, exibirá no console da aplicação o corpo da requisição (em XML) enviada aos Correios. Utilize caso acredite que algum parâmetro não está sendo passado aos Correios. __Ex:__

```ruby
Correios::Sigep.cancel_shipping({
  show_request: true,
  label_number: 'DL746686536BR',
  request_id: '101001'
})
```

Console:

```
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://cliente.bean.master.sigep.bsb.correios.com.br/">
  <soap:Body>
    <ns1:bloquearObjeto>
      <numeroEtiqueta>DL746686536BR</numeroEtiqueta>
      <idPlp>101001</idPlp>
      <tipoBloqueio>FRAUDE_BLOQUEIO</tipoBloqueio>
      <acao>DEVOLVIDO_AO_REMETENTE</acao>
      <usuario>sigep</usuario>
      <senha>n5f9t8</senha>
    </ns1:bloquearObjeto>
  </soap:Body>
</soap:Envelope>

```
