require "spec_helper"

describe AssignByParts do

  describe "given a ruby object" do

    before(:each) do
      class Bar
        attr_accessor :social_security_number, :foo

        include AssignByParts
        assign_by_parts :social_security_number => {:area => [0, 2],
                                                    :group => [3, 4],
                                                    :serial => [5, 8]},
                        :foo => {:fum => [0, 1],
                                 :faz => [2, 4]}

      end

      @bar = Bar.new
      @bar.social_security_number = "000000000"
      @bar.foo = "FMFAZ"

      # TODO
      #stub(@bar).changed_attributes { [] }
      #stub(@bar).foo_will_change! { true }
      #stub(@bar).social_security_number_will_change! { true }
    end

    context "with an attr_accessor" do
      it "should call setup_assign_by_parts for each field" do
        @bar.should respond_to(:social_security_number_area)
        @bar.should respond_to(:social_security_number_group)
        @bar.should respond_to(:social_security_number_serial)

        @bar.should respond_to(:foo_fum)
        @bar.should respond_to(:foo_faz)
      end

      it "should set a part of the attribute" do
        @bar.foo_fum = "NO"
        @bar.foo.should == "NOFAZ"

        @bar.foo_faz = "BAR"
        @bar.foo.should == "NOBAR"

        @bar.social_security_number_group = "99"
        @bar.social_security_number.should == "000990000"
      end
    end
  end


  describe "given an active record object" do
    before(:all) do
      require 'active_record'
    end

    before(:each) do
      class Baz < ActiveRecord::Base
        class_inheritable_accessor :columns

        def self.columns
          @columns ||= []
        end

        def self.column(name, sql_type = nil, default = nil, null = true)
          columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        end

        column :id, :integer
        column :social_security_number, :string
        column :foo, :string

        include AssignByParts
        assign_by_parts :social_security_number => {:area => [0, 2],
                                                    :group => [3, 4],
                                                    :serial => [5, 8]},
                        :foo => {:fum => [0, 1],
                                 :faz => [2, 4]}

      end

      @baz = Baz.new
      @baz.social_security_number = "000000000"
      @baz.foo = "FMFAZ"

      stub(@baz).changed_attributes { [] }
      stub(@baz).foo_will_change! { true }
      stub(@baz).social_security_number_will_change! { true }
    end

    context "with an attribute" do
      it "should call setup_assign_by_parts for each field" do
        @baz.should respond_to(:social_security_number_area)
        @baz.should respond_to(:social_security_number_group)
        @baz.should respond_to(:social_security_number_serial)

        @baz.should respond_to(:foo_fum)
        @baz.should respond_to(:foo_faz)
      end

      it "should set a part of the attribute" do
        @baz.foo_fum = "NO"
        @baz.foo.should == "NOFAZ"

        @baz.foo_faz = "BAZ"
        @baz.foo.should == "NOBAZ"

        @baz.social_security_number_group = "99"
        @baz.social_security_number.should == "000990000"
      end
    end
  end
end
