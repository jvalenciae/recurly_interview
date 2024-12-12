require 'rails_helper'

RSpec.describe TaxIdentificationNumbersController, type: :controller do
  describe 'POST #validate' do
    let(:valid_params) { { tin: '123456789', country_code: 'AU' } }
    let(:invalid_params) { { tin: '123', country_code: 'AU' } }

    context 'when the TIN is valid' do
      before do
        post :validate, params: valid_params
      end

      it 'returns http status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns valid true in the response' do
        expect(JSON.parse(response.body)['result']).to be true
      end

      it 'returns the formatted TIN in the response' do
        expect(JSON.parse(response.body)['formatted_tin']).to eq('123 456 789')
      end
    end

    context 'when the TIN is invalid' do
      before do
        post :validate, params: invalid_params
      end

      it 'returns http status bad request' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns valid false in the response' do
        expect(JSON.parse(response.body)['result']).to be false
      end

      it 'returns an error message in the response' do
        expect(JSON.parse(response.body)['message']).to eq('TIN format does not match')
      end
    end

    context 'when the TIN is a valid ABN' do
      let(:valid_params) { { tin: '10120000004', country_code: 'AU' } }

      before do
        post :validate, params: valid_params
      end

      it 'returns http status bad request' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns valid false in the response' do
        expect(JSON.parse(response.body)['result']).to be true
      end

      it 'returns organization name' do
        expect(JSON.parse(response.body)['organisation_name']).to be_present
      end

      it 'returns address' do
        expect(JSON.parse(response.body)['address']).to be_present
      end

      it 'returns the formatted TIN in the response' do
        expect(JSON.parse(response.body)['formatted_tin']).to eq('10 120 000 004')
      end
    end

    context 'when the TIN is an invalid ABN' do
      let(:invalid_params) { { tin: '10000000000', country_code: 'AU' } }

      before do
        post :validate, params: invalid_params
      end

      it 'returns http status bad request' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns valid false in the response' do
        expect(JSON.parse(response.body)['result']).to be false
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['message']).to eq('ABN is not registered for GST')
      end
    end
  end
end
