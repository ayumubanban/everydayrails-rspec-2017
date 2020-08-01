FactoryBot.define do
  # p52 テスト内で FactoryBot.create(:user) と書くだけで、簡単に新しいユーザーを作成できる
  # p60 Factory Bot を使う際はユーザーファクトリに対して、（projectによって） owner という名前で参照される場合があると伝えなくてはいけない
  factory :user, aliases: [:owner] do
    first_name "Aaron"
    last_name "Sumner"
    # p56 シーケンス を使ってユニークバリデーションを持つフィールドを扱う
    sequence(:email) { |n| "tester#{n}@example.com"}
    password "dottle-nouveau-pavilion-tights-furze"
  end
end
