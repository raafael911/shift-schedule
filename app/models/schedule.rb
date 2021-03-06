class Schedule < ActiveRecord::Base
  validates :year, presence: true
  validates :week, presence: true
  validates :user_id, presence: true
  validates :version_id, presence: true
  validates :project_id, presence: true
  validates :hours, presence: true
end
