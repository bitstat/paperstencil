class TextareaField < Field
  def validate_field(field)
    field = field.to_s.strip
    if value["required"] and field.empty?
      @error = "This field is required. Please enter a value."
      return false
    end

    min = value["range_min"].to_i
    max = value["range_max"].to_i

    l = value["range_type"] == "characters" ? field.size : field.split(' ').size
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
    field.to_s.strip
  end
end
