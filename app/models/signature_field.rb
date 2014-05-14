class SignatureField < Field

  def validate_field(field)
    field.strip!

    if value["required"] and field.empty?
      @error = "This field is required. Please enter a value."
      return false
    end

    true
  end

  def field_instance(field)
    field.to_s.strip
  end
end
