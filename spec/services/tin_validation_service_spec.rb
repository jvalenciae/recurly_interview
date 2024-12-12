require 'rails_helper'

RSpec.describe TinValidationService do
  describe '#valid_number?' do
    subject { described_class.new(tin, country_code).valid_number? }

    context 'when the TIN and Country Code are valid' do
      let(:tin) { '123456789' }
      let(:country_code) { 'AU' }

      it 'returns true, no error message, and the formatted TIN' do
        response = subject
        expect(response[:result]).to be true
        expect(response[:message]).to be_empty
        expect(response[:formatted_tin]).to eq('123 456 789')
      end
    end

    context 'when the country code does not exist' do
      let(:tin) { '123456789' }
      let(:country_code) { 'XX' }

      it 'returns false, an error message, and an empty formatted TIN' do
        response = subject
        expect(response[:result]).to be false
        expect(response[:message]).to eq('Country code does not exists')
        expect(response[:formatted_tin]).to be_blank
      end
    end

    context 'when the TIN format does not match' do
      let(:tin) { '1234567' }
      let(:country_code) { 'AU' }

      it 'returns false, an error message, and an empty formatted TIN' do
        response = subject
        expect(response[:result]).to be false
        expect(response[:message]).to eq('TIN format does not match')
        expect(response[:formatted_tin]).to be_blank
      end
    end

    context 'when the TIN matches the regex and is a valid ABN for AU' do
      let(:tin) { '10120000004' }
      let(:country_code) { 'AU' }

      it 'returns true, no error message, and the formatted TIN' do
        response = subject
        expect(response[:result]).to be true
        expect(response[:message]).to be_empty
        expect(response[:formatted_tin]).to eq('10 120 000 004')
      end
    end

    context 'when the TIN matches the regex ABN is not found' do
      let(:tin) { '10120000005' }
      let(:country_code) { 'AU' }

      it 'returns false, an error message, and an empty formatted TIN' do
        response = subject
        expect(response[:result]).to be false
        expect(response[:message]).to eq('ABN not found')
        expect(response[:formatted_tin]).to be_blank
      end
    end

    context 'when the TIN matches the regex but ABN is not registered for GST' do
      let(:tin) { '10000000000' }
      let(:country_code) { 'AU' }

      it 'returns false, an error message, and an empty formatted TIN' do
        response = subject
        expect(response[:result]).to be false
        expect(response[:message]).to eq('ABN is not registered for GST')
        expect(response[:formatted_tin]).to be_blank
      end
    end
  end
end
