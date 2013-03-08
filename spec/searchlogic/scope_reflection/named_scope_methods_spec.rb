require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::NamedScopeMethods do 
  context "#joined_named_scopes" do 
    xit "returns nil if there are no named scopes" do 
        Searchlogic::ScopeReflection.joined_named_scopes.should be_nil
      end
    xit "returns a list of all named scopes separated by | in brackets" do 
      class User; scope :late, lambda{created_at_after(Date.today)};end
      class Order; scope :early, lambda{created_at_before(Date.today)};end
      Searchlogic::ScopeReflection.joined_named_scopes.should eq(("late|early"))
    end
  end


  context "#named_scope?" do 
    it "returns true for defined named scopes" do 
      class User; scope :young, lambda{};end
      Searchlogic::ScopeReflection.named_scope?(:young).should be_true
    end
    it "returns false for undefined scopes" do 
      Searchlogic::ScopeReflection.named_scope?(:undefined).should be_false


    end
  end

  context "#all_named_scopes" do 
    it "should return an array of all naemd scopes for all klasses" do 
      existing = Searchlogic::ScopeReflection.all_named_scopes
      class User; scope :one, lambda{};end;
      class Company; scope :two, lambda{};end;
      class LineItem; scope :three, lambda{};end;
      Searchlogic::ScopeReflection.all_named_scopes.sort.should eq((existing + [:two,:one, :three]).sort)
    end
  end  
end