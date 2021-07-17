Gem::Specification.new do |s|
  s.author        = 'Arthur Soares'
  s.email         = 'arthurvsp97@gmail.com'

  s.name          = 'correios_gem'
  s.version       = '1.4.3'
  s.date          = '2019-03-09'
  s.homepage      = 'https://github.com/arthursoas/correios_gem'
  s.summary       = 'A correios-gem integra sua aplicacao com as APIs dos
                     Correios'
  s.description   = 'Integracao com as APIs Sigep, Logistica Reversa,
                     Precificador (frete) e SRO, utilizando objetos Ruby para
                     requisicoes e respostas. Integrar com os Correios nunca foi
                     tao simples.'
  s.license       = 'MIT'
  s.files         = Dir['lib/**/*'] + %w[correios_gem.gemspec]

  s.add_dependency 'activesupport', '~> 6.1',  '>= 6.1.3'
  s.add_dependency 'nokogiri',      '~> 1.9',  '>= 1.9.1'
  s.add_dependency 'savon',         '~> 2.12', '>= 2.12.0'

  s.add_development_dependency 'rspec', '~> 3.0'

  # s.add_development_dependency 'bundler', '~> 1.11'
  # s.add_development_dependency 'rake', '~> 10.0'
  # s.add_development_dependency 'simplecov', '~> 0.14.1'
  # s.add_development_dependency 'coveralls', '~> 0.8.21'
  # s.add_development_dependency 'rubocop', '~> 0.52.1'
end
