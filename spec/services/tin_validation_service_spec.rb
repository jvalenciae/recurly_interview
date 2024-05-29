require 'rails_helper'

RSpec.describe TinValidationService do
  describe '#valid_number?' do
    subject { described_class.new(tin, country_code).valid_number? }

    context 'when the TIN and Country Code are valid' do
      let(:tin) { '12345678901' }
      let(:country_code) { 'AU' }

      it 'returns true, no error message, and the formatted TIN' do
        result, error, formatted_tin = subject
        expect(result).to be true
        expect(error).to be_empty
        expect(formatted_tin).to eq('12 345 678 901')
      end
    end

    context 'when the country code does not exist' do
      let(:tin) { '123456789' }
      let(:country_code) { 'XX' }

      it 'returns false, an error message, and an empty formatted TIN' do
        result, error, formatted_tin = subject
        expect(result).to be false
        expect(error).to eq('Country code does not exists')
        expect(formatted_tin).to be_empty
      end
    end

    context 'when the TIN format does not match' do
      let(:tin) { '1234567' }
      let(:country_code) { 'AU' }

      it 'returns false, an error message, and an empty formatted TIN' do
        result, error, formatted_tin = subject
        expect(result).to be false
        expect(error).to eq('TIN format does not match')
        expect(formatted_tin).to be_empty
      end
    end
  end
end
