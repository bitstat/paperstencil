class PhoneField < Field

  def validate_field(field)
    if value["required"] and value["phone_format"] == "international" and field["international"].to_s.strip.empty?
      @error = "This field is required. Please enter a value."
      return false
    end

    if value["required"] and value["phone_format"] == "other"
      if ['first', 'second', 'third'].any? { |f| field[f].to_s.strip.empty? }
        @error = "This field is required. Please enter a value."
        return false
      end
    end

    if value["phone_format"] == "other"
      if ['first', 'second', 'third'].any? { |f| !field[f].to_s.strip.empty? } and
          ['first', 'second', 'third'].any? { |f| field[f].to_s.strip.size != 3 }
        @error = "Invalid Phone number."
        return false
      end
    end

    # TODO international format validation
    true
  end

  def field_instance(field)
    names = ['first', 'second', 'third']
    v = ""
    if value["phone_format"] == "international"
      v = field["international"].to_s.strip
    elsif value["phone_format"] == "other"
      if names.all? { |f| not field[f].to_s.strip.empty? }
        v = names.map { |f| field[f].to_s.strip }.join("-")
      end
    end

    v
  end
end
