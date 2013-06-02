require 'spec_helper'

describe Manga do
  it 'has a valid factory' do
    FactoryGirl.create(:manga).should be_valid
  end

  it 'is invalid without a title' do
    FactoryGirl.build(:manga, title: nil).should_not be_valid
  end

  it 'is invalid without an author' do
    FactoryGirl.build(:manga, author: nil).should_not be_valid
  end

  it 'returns chapter_urls as json' do
    manga = FactoryGirl.create(:manga)
    manga.json_chapter_urls.should == {"105"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3ZElZZFFlbGd0TDQ&export=download", "106"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3Y3BwQ1JVS2tGMHM&export=download", "107"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3TXRSM0F0Nk1tTU0&export=download", "108"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3aVhVVHBOYk94U1k&export=download", "109"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3TE1KcjNKNUlKTWs&export=download"} 
  end
end
