class Product < ApplicationRecord

  belongs_to :category

  before_create :set_default_atrrs

  private

  def set_default_atrrs
    self.uuid = RandomCode.generate_product_uuid
  end

end
