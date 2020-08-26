# frozen_string_literal: true

# # frozen_string_literal: true

# require "rails_helper"

# describe SessionsController do
#   let(:omniauth) { "user_hash" }
#   let(:user_id) { 42 }
#   let(:user) { User.new(id: user_id) }
#   let(:github_user) { instance_double(Github::User, identify: user) }

#   describe "#create" do
#     before do
#       expect(Github::User).to receive(:new).with(omniauth).and_return(github_user)
#       request.env["omniauth.auth"] = omniauth
#       session[:user_id] = nil
#     end

#     it "saves omniauth object to session" do
#       post :create

#       expect(response).to redirect_to("/")
#       expect(session[:user_id]).to eql(user_id)
#     end
#   end

#   describe "#delete" do
#     before do
#       session[:user_id] = omniauth
#     end

#     it "clears request's session object" do
#       delete :destroy

#       expect(response).to redirect_to("/")
#       expect(session[:user_id]).to be_nil
#     end
#   end
# end
