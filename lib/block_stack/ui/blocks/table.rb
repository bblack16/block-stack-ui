module BlockStack
  class Table < Block

    def self.headers(obj)
      case obj
      when Array
        headers(obj.first)
      when Hash
        obj.keys
      when BlockStack::Model
        return obj.config.table_columns if obj.config.table_columns
        associations = obj.associations.map(&:attribute)
        obj._attrs.reject do |k, v|
          associations.include?(k) && k != :id ||
          k != :id && (v[:options][:singleton] ||
          v[:options].include?(:dformed) && !v[:options][:dformed])
        end.keys.hmap { |k| [k.to_s.gsub('_', ' ').title_case, k] }
      when BBLib::Effortless
        obj._attrs.reject do |k, v|
          k != :id && (v[:options][:singleton] ||
          v[:options].include?(:dformed) && !v[:options][:dformed])
        end.keys.hmap { |k| [k.to_s.gsub('_', ' ').title_case, k] }
      else
        { 'ID': :object_id, 'Name': :to_s, 'Class': :class }
      end
    end

    def default_locals(custom = {})
      {
        data:        [],
        headers:     nil,
        max:         256,
        empty:       nil,
        page_length: 25
      }
    end

    def default_attributes
      {
        class: 'data-table default responsive'
      }
    end

  end
end
