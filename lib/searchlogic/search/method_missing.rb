module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module MethodMissing
        private
          def method_missing(method, *args, &block)
            scope_name = method.to_s.gsub(/=$/, '').to_sym
              ###TODO WHITELIST ALLOWED SCOPES with Eq sign                           

            if !!(/=$/ =~ method) && !!klass.column_names.detect{|kcn| scope_name.to_s.include?(kcn)}
              conditions[scope_name] = args.first
            elsif order = ordering
              conditions_with_ordering(order)
            elsif klass.respond_to?(method.to_sym) && !scope?(method)
              ###TODO trigger this block if klass responds to method && method not a scope
              delegate(method, args, &block)
            elsif !!klass.column_names.detect{|kcn| scope_name.to_s.include?(kcn)}
              ###TODO Use whitelist scope names here w/out equal sign
              args.empty? ? return_value(scope_name) : assign_condition(scope_name, args.first)
            elsif method.to_sym == :all
              chained_conditions
            else
              super
            end
          end

          def return_value(key)
            conditions[key]
          end

          def assign_condition(cond_name, value)
            conditions[cond_name] = value
            self
          end

          def scope?(method)
            /(#{klass.column_names.join("|")})[_]/ =~ method 
          end
          def ordering
            conditions.find{|c, v| (c.to_sym == :ascend_by) || (c.to_sym == :descend_by) }
          end
      end
    end
  end
end