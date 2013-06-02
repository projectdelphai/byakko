require 'spec_helper'

describe UsersController do
  describe "#new" do
    it "creates a new user" do 
      FactoryGirl.create(:user).should be_valid
    end
  end

  describe "#create" do

    it 'creates an api_key' do 
      @user = FactoryGirl.create(:user)
      @user.api_key = SecureRandom.hex
    end

    context "with valid attributes" do
      it "adds user" do
	expect{
	  post :create, user: FactoryGirl.attributes_for(:user)
	}.to change(User, :count).by(1)
      end

      it "signs in user" do
	user = FactoryGirl.attributes_for(:user)
	current_user = user
      end
    end

    context "without valid attributes" do
      it 'does not save user' do
	expect{
	  post :create, user: FactoryGirl.attributes_for(:invalid_user)
	}.to_not change(User, :count) 
      end

      it 'rerenders signup' do
	post :create, user: FactoryGirl.attributes_for(:invalid_user)
	response.should render_template :new 
      end
    end
  end

  describe "#destroy" do
    before :each do
      @user = FactoryGirl.create(:user)
    end
    
    it 'deletes user' do
      expect {
	delete :destroy, id: @user
      }.to change(User, :count).by(-1)
    end
    
    it 'redirects to root_url' do
      delete :destroy, id: @user
      response.should redirect_to root_url
    end    
  end
  
  describe "#show" do
    it 'checks for new manga' do
    end

  end
end
