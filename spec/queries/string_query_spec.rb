require 'logirel/queries'

module Logirel
  module Queries
    describe StrQ, "in its default mode of operation, when reading props" do
      before(:each) { @q = StrQ.new "Q??", "def" }
      subject { @q }
      it { should respond_to :question }
      it { should respond_to :default }
      specify { @q.answer.should eql("def") }
      specify { @q.question.should eql("Q??") }
    end

    describe StrQ, "when feeding it OK input" do
      before(:each) do
        @io = StringIO.new "My Answer"
        @out = StringIO.new
        @validator = double('validator')
        @validator.should_receive(:call).once.
            with(an_instance_of(String)).
            and_return(true)
      end
      subject { StrQ.new("q?", "def", @io, @validator, @out) }
      specify {
        subject.exec.should eql("My Answer") and
            subject.answer.should eql("My Answer")
      }
    end

    describe StrQ, "when feeding it bad input" do
      before(:each) do
        @io = StringIO.new "My Bad Answer\nAnother Bad Answer\nOKAnswer!"
        @out = StringIO.new

        @validator = double('validator')
        @validator.should_receive(:call).exactly(3).times.
            with(an_instance_of(String)).
            and_return(false, false, true)
      end
      subject { StrQ.new("q?", "def", @io, @validator, @out) }
      specify { subject.exec.should == "OKAnswer!" }
    end

    describe StrQ, "when accepting the defaults" do
      before(:each) do
        @io = StringIO.new "\n"
        @out = StringIO.new

        @validator = double('validator')
        @validator.should_receive(:call).once.
            with(an_instance_of(String)).
            # the validator should be called for empty input once if we have a default, directly when defaulting with validator{true}
        and_return(true)
      end
      subject { StrQ.new("q?", "def", @io, @validator, @out) }
      specify {
        subject.exec.should eql("def") and
            subject.answer.should eql("def")
      }
    end
  end
end
