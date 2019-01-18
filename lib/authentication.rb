module Correios
  class Authentication
    attr_accessor :sigep_user,
                  :sigep_password,
                  :administrative_code,
                  :contract,
                  :card,
                  :cnpj,
                  :reverse_logistics_user,
                  :reverse_logistics_password,
                  :sro_user,
                  :sro_password

    def initialize
      self.sigep_user =                 sigep_user
      self.sigep_password =             sigep_password
      self.administrative_code =        administrative_code
      self.contract =                   contract
      self.card =                       card
      self.cnpj =                       cnpj
      self.reverse_logistics_user =     reverse_logistics_user
      self.reverse_logistics_password = reverse_logistics_password
      self.sro_user =                   sro_user
      self.sro_password =               sro_password
    end
  end
end
