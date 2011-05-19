module AssignByParts
  class Railtie < Rails::Railtie
    initializer "assign_by_parts.initialize" do |app|
      ActiveRecord::Base.send :include, AssignByParts if defined?(ActiveRecord)
    end
  end
end
