class College < ApplicationRecord
  has_many :departments, dependent: :destroy, inverse_of: :college

  validates :name, presence: true, uniqueness: true

  def name
    return super if super.blank?
    I18n.t("db.colleges.#{super.parameterize(separator: '_')}", default: super)
  end
end
