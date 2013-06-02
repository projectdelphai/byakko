require 'spec_helper'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  it 'is invalid without a username' do
    FactoryGirl.build(:user, username: nil).should_not be_valid
  end

  it 'is invalid without a password' do
    FactoryGirl.build(:user, password: nil).should_not be_valid
  end

  it 'is invalid without a password confirmation' do
    FactoryGirl.build(:user, password_confirmation: nil).should_not be_valid
  end

  it "returns a user's subscription as an array of hashes" do
    user = FactoryGirl.create(:user)
    user.json_subscription.should == [{ "title" => "Berserk", "chapter" => "333" }, { "title" => "Bleach", "chapter" => "538" }, { "title" => "Noblesse", "chapter" => "285" }] 
  end
    


end
