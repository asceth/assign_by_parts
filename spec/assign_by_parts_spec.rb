require "spec_helper"

describe AssignByParts do

  describe "given a hash" do

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
