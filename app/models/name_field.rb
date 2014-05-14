class NameField < Field
  def validate_field(field)
    if value["required"] and (field["first"].to_s.strip.empty? || field["last"].to_s.strip.empty?)
      @error = "This field is required. Please enter a value."
      return false
    end

    if value["required"] and value["name_format"] == "extended" and (field["title"].to_s.strip.empty? || field["suffix"].to_s.strip.empty?)
      @error = "This field is required. Please enter a value."
      return false
    end

    true
  end

  def field_instance(field)
    v = {}
    ['first', 'last', 'title', 'suffix'].each do |f|
      v[f] = field[f].to_s.strip
    end
    v['name_format'] = value['name_format']
    v
  end
end
