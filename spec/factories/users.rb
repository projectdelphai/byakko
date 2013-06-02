FactoryGirl.define do
  factory :user do |f|
    f.username "testuser"
    f.password "password"
    f.password_confirmation "password"
    f.api_key nil

    f.subscription YAML.dump([ { "title" => "Berserk", "chapter" => "333" }, { "title" => "Bleach", "chapter" => "538" }, { "title" => "Noblesse", "chapter" => "285" } ])
  end

  factory :invalid_user, parent: :user do |f|
    f.username nil
  end
end
