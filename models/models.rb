class Account
  include DataMapper::Resource

  property :id, Serial
  property :provider, Text
  property :uid, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user

end

class User
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :update_at, DateTime

  property :name, String, :required => true
  # Role:
  # 0: not yet approved
  # 1: group leader
  # 2: admin
  property :role, Integer, :default => 0, :required => true

  has n, :accounts
  has n, :announcements

  def role_name
    case self.role
    when 0
      "Unapproved"
    when 1
      "Group leader"
    when 2
      "Admin"
    end
  end

end

class Announcement
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :update_at, DateTime
  property :title, String, :required => true
  property :content, Text, :required => true

  belongs_to :user
end

