class Merchant < ApplicationRecord
  validates_presence_of :name
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

  enum status: [:disabled, :enabled]

end
