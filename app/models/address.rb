class Address < ApplicationRecord

  validates :user_id, presence: true
  validates :address_type, presence: true
  validates :contact_name, presence: { message: "收货人不能为空" }
  validates :cellphone, presence: { message: "手机号不能为空" }
  validates :address, presence: { message: "地址不能为空" }

  belongs_to :user

  module AddressType
    User = 'user'
    Order = 'order'
  end
end
