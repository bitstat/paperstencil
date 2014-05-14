class CheckboxField < Field
  def validate_field(field)
    if value["required"] and field.values.all? { |x| x == "-1" }
      @error = "This field is required. Please select a value."
      return false
    end
    true
  end

  def field_instance(field)
    v = field && field.values.reject {|f| f == "-1" }.map { |f| value["checkboxes"][f.to_i]["text"] }
    v
  end
end
