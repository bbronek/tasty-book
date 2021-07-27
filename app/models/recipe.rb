# frozen_string_literal: true

class Recipe < ApplicationRecord
  validates :title, presence: true
  validates :how_to_prepare, presence: true
  validates :time_needed, presence: true
  enum difficulty: {"EASY": 0, "MEDIUM": 1, "HARD": 2}

  has_many :recipe_scores,
    dependent: :destroy

  has_many :scorers,
    through: :recipe_scores,
    source: :user

  has_many :comments, dependent: :destroy

  has_and_belongs_to_many :ingredients
end
