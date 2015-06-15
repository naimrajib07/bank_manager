class Transaction < ActiveRecord::Base
  # allow type column to avoid single table inheritance
  self.inheritance_column = nil

  DEBIT = 'Dr'
  CREDIT = 'Cr'

  belongs_to :bank_account

  validates_numericality_of :amount, :greater_than_or_equal_to => 0, message: 'invalid amount'
end
