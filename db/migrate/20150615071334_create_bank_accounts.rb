class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.float :balance, default: 0.0
      t.references :user, index: true

      t.timestamps
    end
  end
end
