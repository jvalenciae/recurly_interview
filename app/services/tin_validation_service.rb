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
    return [false, 'Country code does not exists', ''] unless FORMATS[country_code]

    result = nil
    format_used = nil

    FORMATS[country_code].each do |format|
      regex = format_to_regex(format)
      next unless tin.match?(regex)

      next if country_code == 'AU' && tin.length == 11 && !AbnValidationService.new(tin).valid_abn?

      result = true
      format_used = format
      break
    end

    return [false, 'TIN format does not match', ''] unless result

    [true, '', format_tin(tin, format_used)]
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
