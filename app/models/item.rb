class Item < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :description
  validates :unit_price, presence: true, format: { with: /\A\d{0,11}(\.?\d{0,2})?\z/ }, numericality: true
  belongs_to :merchant
  has_many :discounts, through: :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :users, through: :invoices

  enum status: [ :disabled, :enabled ]

  def best_discount(quantity)
    discounts.where('discounts.minimum <= ?', quantity).order(percentage: :desc).limit(1).first
  end

  def discounts?
    discounts.count > 0
  end

  def best_day
    invoices.select('invoices.created_at AS created_at, SUM(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
    .group('invoices.created_at')
    .max
    .date
  end
end
