class AddressField < Field
  def validate_field(field)
    address_fields = ['line1', 'line2', 'city', 'state', 'zip', 'country']
    filled_fields = address_fields.map { |f| field[f].to_s.strip }.reject(&:empty?).size

    if value["required"]
      if filled_fields != 6
        @error = "This field is required. Please enter a value."
        return false
      end
    end

    if filled_fields > 1 && filled_fields < 6
      @error = "Please enter a value for all sections."
      return false
    end

    true
  end

  def field_instance(field)
    v = {}
    address_fields = ['line1', 'line2', 'city', 'state', 'zip', 'country']
    if address_fields.all? { |f| not field[f].strip.empty? }
      address_fields.each { |f| v[f] = field[f].strip }
    end
    v
  end
end
