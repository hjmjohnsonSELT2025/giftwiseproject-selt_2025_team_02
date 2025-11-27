require "rails_helper"

RSpec.describe Event, type: :model do
  let(:user) do
    User.create!(
      name: "Chad",
      email: "chad_bro_chill@fakemail.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  describe "validations and associations" do
    it "is valid with a name, event_date, and user" do
      event = Event.new(
        name: "Beer oclock",
        event_date: Date.today + 4,
        user: user
      )

      expect(event.valid?).to eq(true)
    end

    it "is invalid without a name" do
      event = Event.new(
        name: nil,
        event_date: Date.today + 4,
        user: user
      )

      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an event_date" do
      event = Event.new(
        name: "Beer oclock",
        event_date: nil,
        user: user
      )

      expect(event).not_to be_valid
      expect(event.errors[:event_date]).to include("can't be blank")
    end

    it "is invalid without a user" do
      event = Event.new(
        name: "Beer oclock",
        event_date: Date.today + 4,
        user: nil
      )

      expect(event).not_to be_valid
      expect(event.errors[:user]).to include("must exist")
    end
  end

  describe "budget validation" do
    # Helper for budget-related errors: builds an otherwise-valid event so the only thing that can fail is the budget field.
    def budget_errors_for(value)
      event = described_class.new(
        name:       "Test event",
        event_date: Date.today,
        user:       user,
        budget:     value
      )

      event.validate
      event.errors[:budget]
    end

    context "with valid plain number budgets" do
      it "allows nil (no budget set)" do
        expect(budget_errors_for(nil)).to be_empty
      end

      it "allows zero" do
        expect(budget_errors_for(0)).to be_empty
        expect(budget_errors_for("0")).to be_empty
        expect(budget_errors_for("0.00")).to be_empty
      end

      it "allows positive numbers up to the max" do
        expect(budget_errors_for(12.34)).to be_empty
        expect(budget_errors_for("999999.99")).to be_empty
        expect(budget_errors_for(1_000_000)).to be_empty
      end

      it "allows large plain numbers that would equal scientific notation" do
        expect(budget_errors_for(40_000)).to be_empty
        expect(budget_errors_for("40000")).to be_empty
      end
    end

    context "with out-of-range budgets" do
      it "rejects negative budgets" do
        expect(budget_errors_for(-0.01)).not_to be_empty
        expect(budget_errors_for("-10")).not_to be_empty
      end

      it "rejects budgets above 1,000,000" do
        expect(budget_errors_for(1_000_000.01)).not_to be_empty
        expect(budget_errors_for("1000000.01")).not_to be_empty
      end
    end

    context "with scientific notation budgets" do
      let(:scientific_msg) do
        "must be a plain number (scientific notation not allowed)"
      end

      it "rejects lowercase 'e' notation" do
        expect(budget_errors_for("4e4")).to include(scientific_msg)
      end

      it "rejects uppercase 'E' notation" do
        expect(budget_errors_for("1E6")).to include(scientific_msg)
      end

      it "rejects signed exponents" do
        expect(budget_errors_for("3.2e+2")).to include(scientific_msg)
      end

      it "still rejects scientific notation even if the value is in range" do
        expect(budget_errors_for("1e3")).to include(scientific_msg)
      end
    end
  end
end
