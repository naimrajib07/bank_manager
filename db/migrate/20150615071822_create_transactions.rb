class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.float :amount, default: 0.0
      t.string :type
      t.integer :ref_transaction_id
      t.references :bank_account, index: true

      t.timestamps
    end
  end
end
