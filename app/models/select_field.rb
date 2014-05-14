class SelectField < Field
  def validate_field(field)
    field.strip!
    if value["required"] and field.empty?
      @error = "This field is required. Please select a value."
      return false
    end
    true
  end

  def field_instance(field)
    value["options"][field.to_i]["text"]
  end
end
