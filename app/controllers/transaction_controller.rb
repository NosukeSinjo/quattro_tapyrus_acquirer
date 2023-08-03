class TransactionsController < ApplicationController
    def new; end
  
    def show
      @transaction = current_telegram
    end
    
    def create
      @transaction = transaction.new(transaction_params)
      if @transaction.save!
        flash[:notice] = "登録が完了しました"
        redirect_to root_path
      else
        render 'new'
      end
    end
  
    private
    def merchant_params
      params.require(:telegram).permit(:did, :acquirerId, :amount, :merchant_name, :transactionTime)
    end
  end
  