module AssignByParts

  def self.included base
    require 'active_support/core_ext/string' # lazy load
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
          #{sorted_part_definitions.inspect}
        end

        def update_#{attribute}(parts)
          new_attribute = new_#{attribute}_from_parts(merge_#{attribute}_parts(parts))
          if defined?(ActiveRecord) && self.is_a?(ActiveRecord::Base)
            #{attribute}_will_change! unless changed_attributes.include?('#{attribute}')
            self[:#{attribute}] = new_attribute
          else
            @#{attribute} = new_attribute
          end
        end

        def new_#{attribute}_from_parts(parts)
          #{attribute}_part_definitions.inject("") do |value, part_definition|
            part_value = parts[part_definition.first]
            part_definition_size = part_definition.last.last - part_definition.last.first + 1
            value + (("%" + (part_definition_size).to_s + "s") % part_value[0..part_definition_size])
          end
        end

        def merge_#{attribute}_parts(parts)
          #{attribute}_part_definitions.inject({}) do |combination, (part_key, range)|
            combination[part_key] = parts[part_key] || send(("#{attribute}_" + part_key.to_s).to_sym)
            combination
          end
        end
      EOS

      sorted_part_definitions.each do |(part_key, (beginning_of_part, end_of_part))|
        class_eval <<-EOS, __FILE__, (__LINE__+1)
          def #{attribute}_#{part_key}
            #{attribute}.blank? ? "" : #{attribute}[#{beginning_of_part}..#{end_of_part}]
          end

          def #{attribute}_#{part_key}=(value)
            update_#{attribute}(:#{part_key} => value)
          end
        EOS
      end
    end
  end
end
