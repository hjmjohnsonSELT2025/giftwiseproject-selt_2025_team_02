require 'rails_helper'
require 'ostruct'

RSpec.describe AiGiftService do

  let(:user) { User.create(email: "test@example.com", password: "password") }
  let(:recipient) { Recipient.create(name: "Dad", relation: "father", age: 60, likes: "fishing", dislikes:"war", user: user) }
  subject { described_class.new(recipient) }

  describe '#suggest_gift' do
    let(:openai_client) { instance_double(OpenAI::Client) }

    # fake response structure that acts like openai's real JSON
    let(:fake_response) do
      OpenStruct.new(
        choices: [
          OpenStruct.new(
            message: OpenStruct.new(content: "1. fishing rod \n 2. dr. pepper")
          )
        ]
      )
    end

    before do
      #seam
      allow(OpenAI::Client).to receive(:new).and_return(openai_client)

      allow(openai_client).to receive_message_chain(:chat, :completions, :create).and_return(fake_response)
    end

    it 'calls OpenAI and returns the suggestions content' do
      result = subject.suggest_gift

      expect(result).to eq("1. fishing rod \n 2. dr. pepper")
    end
  end
end