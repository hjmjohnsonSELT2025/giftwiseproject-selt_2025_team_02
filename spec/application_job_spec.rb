require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it "inherits from ActiveJob::Base" do
    expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
  end
  it "can be instantiated" do
    expect(ApplicationJob.new).to be_a(ActiveJob::Base)
  end
end