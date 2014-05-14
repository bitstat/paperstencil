require 'date'

class DateField < Field
  def validate_field(field)
    if value["required"] and ['mm', 'dd', 'yyyy'].any? { |f| field[f].strip.empty? }
      @error = "This field is required. Please select a value."
      return false
    end

    if not value["required"] and ['mm', 'dd', 'yyyy'].all? { |f| field[f].strip.empty? }
      return true
    end

    begin
      month, day, year = *['mm', 'dd', 'yyyy'].map { |f| Integer(field[f]) }
      date = Date.new(year, month, day)
    rescue ArgumentError
      @error = "Invalid date. Please select a valid date"
      return false
    end
    return true
  end

  def field_instance(field)
    v = {}
    if ['mm', 'dd', 'yyyy'].all? { |f| not field[f].strip.empty? }
      ['mm', 'dd', 'yyyy'].each { |f| v[f] = field[f].strip }
    end
    v
  end
end
