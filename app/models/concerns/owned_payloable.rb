module OwnedPayloable
  extend ActiveSupport::Concern

  def self.name_regex
    '[\w\.-]+(\/{0,1}[\w\.-]+)+'
  end

  included do
    has_and_belongs_to_many :users,
      class_name: 'Atmosphere::User'

    validates :payload,
      presence: true

    validates :name,
      presence: true,
      uniqueness: true,
      format: { with: /\A#{OwnedPayloable.name_regex}\z/ }
  end
end
