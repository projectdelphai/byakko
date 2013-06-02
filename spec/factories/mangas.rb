FactoryGirl.define do
  factory :manga do |f|
    f.title "The God of High School"
    f.author "PARK Yong-Je"
    f.latestchapter "109"
    f.cover nil
    f.chapter_urls YAML.dump({"105"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3ZElZZFFlbGd0TDQ&export=download", "106"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3Y3BwQ1JVS2tGMHM&export=download", "107"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3TXRSM0F0Nk1tTU0&export=download", "108"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3aVhVVHBOYk94U1k&export=download", "109"=>"https://docs.google.com/uc?id=0Bz4Cdjh9cTq3TE1KcjNKNUlKTWs&export=download"})
  end
end
