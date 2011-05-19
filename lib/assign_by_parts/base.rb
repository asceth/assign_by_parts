module AssignByParts

  def self.included base
    base.send :extend, ClassMethods
  end

  module PrivateClassMethods
    attr_accessor :initial_value
  end
  extend PrivateClassMethods

  module ClassMethods
    def assign_by_parts(*args)
      case args.length
      when 1 then
        args.first.each {|attribute, part_definitions| setup_assign_by_parts(attribute, part_definitions)}
      when 2 then
        setup_assign_by_parts *args
      else raise("Error in assign_by_parts syntax, expecting attribute and part definitions or a hash, got #{args.inspect}")
      end
    end

    private

    def setup_assign_by_parts(attribute, part_definitions)
      sorted_part_definitions = part_definitions.to_a.sort_by do |(part_key, (beginning_of_part, end_of_part))|
        beginning_of_part
      end
      sorted_part_definition_keys = sorted_part_definitions.map(&:first)

      class_eval <<-EOS, __FILE__, (__LINE__+1)
        def #{attribute}_part_definitions
          #{sorted_part_definitions}
        end

        def update_#{attribute}(parts)
          #{attribute}_will_change! unless changed_attributes.include?('#{attribute}')
          self[:#{attribute}] = new_attribute_from(merge_parts(parts))
        end

        def new_#{attribute}_from_parts(parts)
          #{attribute}_part_definitions.inject("") do |value, part_definition|
            part_value = parts[part_definition.first]
            value + (("%" + (part_definition.last.last - part_definition.last.first + 1).to_s + "s") % part_value[part_definition.last.first..part_definition.last.last])
          end
        end

        def merge_#{attribute}_parts(parts)
          #{sorted_part_definition_keys}.inject({}) do |combination, part_key|
            combination[part_key] = parts[part_key] || send(("#{attribute}_" + part_key).to_sym)
          end
        end
      EOS

      sorted_part_definitions.each do |(part_key, (beginning_of_part, end_of_part))|
        class_eval <<-EOS, __FILE__, (__LINE__+1)
          def #{attribute}_#{part_key}
            #{attribute}.blank? ? "" : #{attribute}[beginning_of_part..end_of_part]
          end

          def #{attribute}_#{part_key}=(value)
            update_#{attribute}(:#{part_key} => value)
          end
        EOS
      end
    end
  end
end
