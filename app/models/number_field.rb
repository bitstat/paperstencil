class NumberField < Field
  def validate_field(field)
    field.strip!

    if value["required"] and field.empty?
      @error = "This field is required. Please enter a value."
      return false
    end

    if (not value["required"]) and field.empty?
      return true
    end

    if not (number = Integer(field) rescue nil)
      @error = "Invalid Number."
      return false
    end

    min = value["range_min"].to_i
    max = value["range_max"].to_i

    l = value["range_type"] == "value" ? number : number.to_s.size

    if max > 0 and l > max
      @error = "This field can have #{max} #{value["range_type"]} atmost"
      return false
    end

    if min > 0 and l < min
      @error = "This field must have #{min} #{value["range_type"]} atleast"
      return false
    end
    true
  end

  def field_instance(field)
    v = field.empty? ? nil : Integer(field)
    v
  end
end
