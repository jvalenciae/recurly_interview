class TinValidationService
  attr_accessor :tin, :country_code

  FORMATS = {
    'AU' => ['NN NNN NNN NNN', 'NNN NNN NNN'],
    'CA' => ['NNNNNNNNNRT00001'],
    'IN' => ['NNXXXXXXXXXXNAN']
  }.freeze

  def initialize(tin, country_code)
    @tin = tin
    @country_code = country_code
  end

  def valid_number?
    return { result: false, message: 'Country code does not exists' } unless FORMATS[country_code]

    response = { result: false, message: 'TIN format does not match', organisation_name: nil, address: {} }

    FORMATS[country_code].each do |format|
      regex = format_to_regex(format)
      next unless tin.match?(regex)

      if country_code == 'AU' && tin.length == 11
        response[:local_validation] = AbnValidationService.new(tin).local_valid_abn?
        response.merge!(AbnValidationService.new(tin).external_valid_abn?)
        next if response[:local_validation].blank? || response[:ext_validation_result].blank?
      end

      response[:result] = true
      response[:format_used] = format
      response[:message] = ''
      break
    end

    response[:formatted_tin] = format_tin(tin, response[:format_used]) if response[:result]
    response
  end

  private

  def format_to_regex(format)
    regex_str = format.chars.map do |char|
      case char
      when 'N'
        '\\d'
      when 'A'
        '[^\\d]'
      when 'X'
        '[a-zA-Z\\d]'
      end
    end.join
    /\A#{regex_str}\z/
  end

  def format_tin(tin, format)
    formatted = ''
    tin_idx = 0

    format.chars.each do |char|
      if %w[N A X].include?(char)
        formatted << tin[tin_idx]
        tin_idx += 1
      else
        formatted << char
      end
    end

    formatted
  end
end
