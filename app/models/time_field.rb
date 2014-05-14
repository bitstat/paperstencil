class TimeField < Field
  def validate_field(field)
    if value["required"] and ['h','m','s'].all? { |f| field[f].strip.empty? }
      @error = "This field is required. Please select a value."
      return false
    end

    if not ['h','m','s'].all? { |f| field[f].strip.empty? }
      begin
        h, m, s = *['h', 'm', 's'].map do |f|
          t = field[f].strip
          t = t.empty? ? 0 : Integer(t)
          field[f] = t.to_s
          t
        end
        today = Time.new

        h += 12 if field['ampm'] == 'pm'
        t = Time.new(today.year, today.month, today.day, h, m, s)
      rescue ArgumentError
        @error = "Invalid Time"
        return false
      end
    end

    return true
  end

  def field_instance(field)
    v = {}

    if not ['h','m','s', 'ampm'].all? { |f| field[f].strip.empty? }
      ['h', 'm', 's', 'ampm'].each { |f| v[f] = field[f].strip }
    end

    v
  end
end
