class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  validates_presence_of :name
  validates :percentage, numericality: {less_than_or_equal_to: 100}, presence: true
  validates :minimum, numericality: { only_integer: true }, presence: true

  before_save :better_discount?
  before_update :pending_invitems?

  def pending_invitems?
    invitems = invoice_items.where(status: :pending, discount_id: (self.id))
    invitems.count > 0
  end

  def better_discount?
    better = Discount.all.where('discounts.percentage >= :percent AND discounts.minimum < :quantity', percent: self.percentage, quantity: self.minimum)
    better.count > 0 ? true : false
  end
end
