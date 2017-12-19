# encoding: UTF-8

class AnexoEfecto < ActiveRecord::Base
  belongs_to :efecto, class_name: '::Efecto',
    foreign_key: 'efecto_id'
  belongs_to :sip_anexo, class_name: 'Sip::Anexo', 
    foreign_key: 'anexo_id', validate: true

  accepts_nested_attributes_for :sip_anexo, reject_if: :all_blank 
  
  validates :efecto, presence: true
  validates :sip_anexo, presence: true
end
