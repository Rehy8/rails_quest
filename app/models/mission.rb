class Mission < ApplicationRecord
  belongs_to :agent

  validates :title, presence: true

  enum :status, {
     assigned: "assigned",
     in_progress: "in_progress",
     completed: "completed"
  }

  validates :status, presence: true
end
