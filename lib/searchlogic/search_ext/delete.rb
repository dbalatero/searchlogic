module Searchlogic
  module SearchExt
    module Delete
      def delete_condition(args)
        args = args.first if args.kind_of?(Array)
        conditions.delete(args.to_sym) 
        conditions.delete(args)
      end
    end
  end
end
