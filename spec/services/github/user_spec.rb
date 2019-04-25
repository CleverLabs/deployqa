# frozen_string_literal: true

require "rails_helper"

describe Github::User do
  subject(:github_user) { described_class.new(omniauth_hash) }

  let(:new_name) { "Oleg Petrov" }
  let(:new_token) { "TOKEN" }
  let(:omniauth_hash) do
    {
      "provider" => "github",
      "uid" => "1234567",
      "info" => {
        "name" => new_name
      },
      "credentials" => {
        "token" => new_token
      }
    }
  end

  describe "#identify" do
    let(:old_name) { "Petr Olegov" }
    let(:user) { User.new(full_name: old_name) }

    before do
      expect(User).to receive(:find_or_create_by!).with(auth_provider: "github", auth_uid: 1_234_567).and_return(user)
      expect(user).to receive(:update).with(token: new_token)
      expect(user).to receive(:update).with(full_name: new_name)
    end

    it "receives record from DB and updates full_name in case of mismatch" do
      expect(github_user.identify).to eql(user)
    end
  end
end
