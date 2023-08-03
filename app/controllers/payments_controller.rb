class PaymentsController < ApplicationController
  def new; end

  def create
    did = payment_params[:did]
    amount = payment_params[:amount].to_i

    message = SecureRandom.uuid
    message_digest = Digest::SHA256::digest(message).bth
    nonce = 1 + SecureRandom.random_number(ECDSA::Group::Secp256k1.order - 1)

    params_json = {
    "transaction": {
        "did": did,
        "acquirerId": current_merchant.id.to_s,
        "amount": amount,
        "merchantName": current_merchant.merchant_name,
        "transactionTime": DateTime.now.to_s
      },
      "didVerification": {
        "messageDigest": message_digest,
        "nonce": nonce 
      }
    }.to_json

    response = Net::HTTP.post(
      URI("#{ENV['BRAND_URL']}/authorization"),
      params_json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)
    authorization = body['authorization']
    signature = body['signature']

    unless authorization
      redirect_to payments_failure_path(reason: '残高不足')
      return
    end

    # TODO: resolve DID
    # TODO: get signing key (w/o privkey)
    signing_key = {
      "kty": "EC",
      "crv": "secp256k1",
      "x": "EVxNqOJkIOzyshVoIaS0gMUlFJIt4mP57Zsscbi1Yyo",
      "y": "SGzyJpL_48ejgEl6AGoHBf91zChW1j2TU_fd64Qsrho"
    }

    params_json = {
      "signature": signature,
      "messageDigest": message_digest,
      "signingKey": signing_key.to_json
    }.to_json
    response = Net::HTTP.post(
      URI("#{ENV['DID_SERVICE_URL']}/did/verify"),
      params_json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)
    success = body['success']

    if success
      redirect_to payments_success_path
    else
      redirect_to payments_failure_path(reason: '検証失敗')
    end
  end
  
  def success; end
  
  def failure
    @reason = params[:reason]
  end
  
  private
  
  def payment_params
    params.require(:payment).permit(:did, :amount)
  end
end
