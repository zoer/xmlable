XMLable::Builder.tap do |b|
  b.define_type :string, :str, String do
    cast { |val| val.to_s }
  end

  b.define_type :integer, :int, Integer do
    cast { |val| val.to_i }
    export_to_json { |val| val }
  end

  b.define_type :float, Float do
    cast { |val| val.to_f }
    export_to_json { |val| val }
  end


  b.define_type :date, Date do
    cast do |val|
      Date.parse(val) if val.is_a?(String) && !val.empty?
    end
    export { |val| val.is_a?(Date) ? val.to_s : val }
  end

  b.define_type :bool, :boolean do
    cast do |val|
      !['false', '0', ''].include?(val.to_s.downcase)
    end

    export_to_json { |val| val }
  end
end
