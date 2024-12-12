class TaxIdentificationNumbersController < ApplicationController
  def validate
    response = TinValidationService.new(tin_params[:tin], tin_params[:country_code]).valid_number?

    if response[:result]
      render json: response, status: :ok
    else
      render json: response, status: :unprocessable_entity
    end
  end

  private

  def tin_params
    params.permit(:tin, :country_code)
  end
end
