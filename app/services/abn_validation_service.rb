require 'nokogiri'
require 'net/http'

class AbnValidationService
  attr_accessor :abn

  WEIGHTING = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19].freeze
  ENDPOINT_URL = 'http://localhost:8080/queryABN'.freeze

  def initialize(abn)
    @abn = abn
  end

  def local_valid_abn?
    new_abn = (abn[0].to_i - 1).to_s + abn[1..]
    sum = 0
    new_abn.chars.each_with_index do |digit, index|
      sum += (digit.to_i * WEIGHTING[index])
    end
    (sum % 89).zero?
  end

  def external_valid_abn?
    xml_response = fetch_response

    if xml_response.blank?
      { ext_validation_result: false, message: 'Error with external service' }.compact
    else
      parse_and_validate_response(xml_response)
    end
  end

  private

  def fetch_response
    uri = URI("#{ENDPOINT_URL}?abn=#{abn}")
    Net::HTTP.get(uri)
  end

  def parse_and_validate_response(xml_data)
    doc = Nokogiri::XML(xml_data)

    gst = doc.at_xpath('//goodsAndServicesTax')&.content
    organisation_name = doc.at_xpath('//organisationName')&.content
    state_code = doc.at_xpath('//address/stateCode')&.content
    postcode = doc.at_xpath('//address/postcode')&.content

    message = if gst.nil?
                'ABN not found'
              elsif gst == 'false'
                'ABN is not registered for GST'
              else
                ''
              end
    { ext_validation_result: gst == 'true', organisation_name:, address: { state_code:, postcode: }, message: }.compact
  end
end
