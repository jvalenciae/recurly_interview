class TaxIdentificationNumbersController < ApplicationController
  def validate
    result, error, formatted_tin = TinValidationService.new(tin_params[:tin], tin_params[:country_code]).valid_number?

    if result
      render json: { valid: true, formatted_tin: }, status: :ok
    else
      render json: { valid: false, message: error }, status: :bad_request
    end
  end

  private

  def tin_params
    params.permit(:tin, :country_code)
  end
end
