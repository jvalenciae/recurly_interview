require 'rails_helper'

RSpec.describe TaxIdentificationNumbersController, type: :controller do
  describe 'POST #validate' do
    let(:valid_params) { { tin: '12345678901', country_code: 'AU' } }
    let(:invalid_params) { { tin: '123', country_code: 'AU' } }

    context 'when the TIN is valid' do
      before do
        allow_any_instance_of(TinValidationService).to receive(:valid_number?).and_return([true, nil, '12 345 678 901'])
        post :validate, params: valid_params
      end

      it 'returns http status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns valid true in the response' do
        expect(JSON.parse(response.body)['valid']).to be true
      end

      it 'returns the formatted TIN in the response' do
        expect(JSON.parse(response.body)['formatted_tin']).to eq('12 345 678 901')
      end
    end

    context 'when the TIN is invalid' do
      before do
        allow_any_instance_of(TinValidationService).to receive(:valid_number?).and_return([false, 'TIN format does not match', nil])
        post :validate, params: invalid_params
      end

      it 'returns http status bad request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns valid false in the response' do
        expect(JSON.parse(response.body)['valid']).to be false
      end

      it 'returns an error message in the response' do
        expect(JSON.parse(response.body)['message']).to eq('TIN format does not match')
      end
    end
  end
end
