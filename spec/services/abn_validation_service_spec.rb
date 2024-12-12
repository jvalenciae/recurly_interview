require 'rails_helper'

RSpec.describe AbnValidationService do
  describe '#local_valid_abn?' do
    subject { described_class.new(abn).local_valid_abn? }

    context 'when the ABN is valid' do
      let(:abn) { '10120000004' }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the ABN is invalid' do
      let(:abn) { '10120000005' }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when the ABN has an incorrect length' do
      let(:abn) { '123456789' }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#external_valid_abn?' do
    let(:abn) { '10000000000' }
    let(:service) { described_class.new(abn) }

    context 'when the external service returns a valid response with GST registration' do
      before do
        stub_request(:get, "http://localhost:8080/queryABN?abn=#{abn}")
          .to_return(status: 200, body: <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <abn_response>
              <response>
                <businessEntity>
                  <goodsAndServicesTax>true</goodsAndServicesTax>
                  <organisationName>Example Company Pty</organisationName>
                  <address>
                    <stateCode>NSW</stateCode>
                    <postcode>2001</postcode>
                  </address>
                </businessEntity>
              </response>
            </abn_response>
          XML
          )
      end

      it 'returns the correct validation result and business information' do
        result = service.external_valid_abn?
        expect(result[:ext_validation_result]).to be true
        expect(result[:organisation_name]).to eq('Example Company Pty')
        expect(result[:address][:state_code]).to eq('NSW')
        expect(result[:address][:postcode]).to eq('2001')
        expect(result[:message]).to be_empty
      end
    end

    context 'when the external service returns a valid response without GST registration' do
      before do
        stub_request(:get, "http://localhost:8080/queryABN?abn=#{abn}")
          .to_return(status: 200, body: <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <abn_response>
              <response>
                <businessEntity>
                  <goodsAndServicesTax>false</goodsAndServicesTax>
                  <organisationName>Example Company Pty</organisationName>
                  <address>
                    <stateCode>NSW</stateCode>
                    <postcode>2001</postcode>
                  </address>
                </businessEntity>
              </response>
            </abn_response>
          XML
          )
      end

      it 'returns the correct validation result and message' do
        result = service.external_valid_abn?
        expect(result[:ext_validation_result]).to be false
        expect(result[:message]).to eq('ABN is not registered for GST')
      end
    end

    context 'when the external service returns an invalid response' do
      before do
        stub_request(:get, "http://localhost:8080/queryABN?abn=#{abn}")
          .to_return(status: 200, body: <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <abn_response>
              <response>
                <businessEntity>
                </businessEntity>
              </response>
            </abn_response>
          XML
          )
      end

      it 'returns the correct validation result and message' do
        result = service.external_valid_abn?
        expect(result[:ext_validation_result]).to be false
        expect(result[:message]).to eq('ABN not found')
      end
    end

    context 'when the external service is not available' do
      before do
        stub_request(:get, "http://localhost:8080/queryABN?abn=#{abn}")
          .to_return(status: 500, body: '')
      end

      it 'returns an error message' do
        result = service.external_valid_abn?
        expect(result[:ext_validation_result]).to be false
        expect(result[:message]).to eq('Error with external service')
      end
    end
  end
end
