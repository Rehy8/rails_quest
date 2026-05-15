class Agent < ApplicationRecord
  has_many :missions, dependent: :destroy
  has_many :agent_skills, dependent: :destroy
  has_many :skills, through: :agent_skills

  validates :codename, presence: true, uniqueness: true
  validates :level, numericality: { in: 1..10 }
end
