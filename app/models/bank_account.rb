class BankAccount < ActiveRecord::Base
  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates_numericality_of :balance, :greater_than_or_equal_to => 0, message: 'invalid amount'

  def deposit(amount)
    if is_valid_amount?(amount)
      self.transaction do
        self.transactions.build(amount: amount, type: Transaction::CREDIT)

        self.balance += amount
        self.save!
      end
    else
      logger.info 'Please check your amount you asked for deposit.'
    end
  end

  def withdraw(amount)
    if eligible_for_balance_transfer(amount)
      self.transaction do
        self.transactions.build(amount: amount, type: Transaction::DEBIT)

        self.balance -= amount
        self.save!
      end
    else
      logger.info 'Please check your amount you asked for withdraw.'
    end
  end

  def balance_transfer(receiver_acc_id, amount)
    if self.id == receiver_acc_id
      logger.info 'Transferring Into Your Own Account does not make sense!! Please Check Your Account Number.'
      return
    end

    if eligible_for_balance_transfer(amount)
      receiver_acc = BankAccount.find(receiver_acc_id)
      raise ActiveRecord::RecordNotFound if receiver_acc.nil?

      self.transaction do
        self.balance -= amount
        receiver_acc.balance += amount

        debit_transaction = self.transactions.create!(amount: amount, type: Transaction::DEBIT)
        credit_transaction = receiver_acc.transactions.create!(amount: amount, type: Transaction::CREDIT, ref_transaction_id: debit_transaction.id)

        debit_transaction.ref_transaction_id = credit_transaction.id

        debit_transaction.save!
        receiver_acc.save!
        self.save!
      end
    else
      logger.info 'You Have Not Sufficient Balance for transfer! Please Check Your Account Balance Before Transfer.'
    end
  end

  def last_transaction_details
    depositor_transaction = self.transactions.last
    depositor = Transaction.find(depositor_transaction.ref_transaction_id).bank_account.user rescue [] if depositor_transaction.present?

    logger.info '================================Last Transaction Details================================'

    if (depositor.present?)
      if depositor_transaction.type == Transaction::DEBIT
        logger.info "Transferred balance to Email: #{depositor.email}, Transferred Amount: #{depositor_transaction.amount} and Transferred Date: #{depositor_transaction.created_at}"
      elsif (depositor_transaction.type == Transaction::CREDIT)
        logger.info "Depositor Email: #{depositor.email}, Deposit Amount: #{depositor_transaction.amount} and Deposited Date: #{depositor_transaction.created_at}"
      end
    else
      if (depositor_transaction.type == Transaction::CREDIT && depositor_transaction.ref_transaction_id.nil?)
        logger.info "You Deposited #{depositor_transaction.amount}  in your account and Deposited Date: #{depositor_transaction.created_at}"
      elsif (depositor_transaction.type == Transaction::DEBIT && depositor_transaction.ref_transaction_id.nil?)
        logger.info "Your withdrawl amount is #{depositor_transaction.amount} and withdrew Date: #{depositor_transaction.created_at}"
      end
    end
  end

  def eligible_for_balance_transfer(amount)
    is_valid_amount?(amount) && (balance - amount) >= 0 ? true : false
  end

  def is_valid_amount?(amount)
    amount > 0 ? true : false
  end
end
