FactoryBot.define do
  factory :note do
    message "My important note."
    association :project
    # p60 上のassociation :projectによってuserはすでに作成されているので、association :user としてもうひとつ余分にuserを作成するのではなく、これで良い
    user { project.owner }
  end
end
