class Department < ApplicationRecord
  belongs_to :college
  has_many :subjects, dependent: :destroy

  validates :name, presence: true

  def name
    return super if super.blank?
    I18n.t("db.departments.#{super.parameterize(separator: '_')}", default: super)
  end
end
