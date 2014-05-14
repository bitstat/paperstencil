class EmailField < Field
  def validate_field(field)
    field = field.to_s.strip
    if value["required"] and field.empty?
      @error = "This field is required. Please enter a value."
      return false
    end

    if (not field.empty?) and (not /.+@.+\..+/ =~ field)
      @error = "Invalid email. Please enter a valid email."
      return false
    end
    true
  end

  def field_instance(field)
    field.to_s.strip
  end
end
