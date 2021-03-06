class Invoice < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [ :cancelled, :in_progress, :completed ]

  def total_revenue
    invoice_items.sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def invoice_complete_update_invoice_items
    update = invoice_items.where.not(discount_id: nil)
    InvoiceItemsWithDiscount.update_percentage(update)
  end

  def discounts_applied
    invitems = invoice_items.pluck(:discount_id).compact
    if !invitems.empty?
      Discount.where(id: invitems)
    else
      false
    end
   end

  def self.incomplete_invoices
    joins(:invoice_items)
    .order(created_at: :asc)
    .where.not(status: 2)
    .where.not("invoice_items.status = ?", 2)
    .distinct
  end

  def customer_name
    user.name
  end
end
