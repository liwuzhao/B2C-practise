class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password, :password_confirmation

  validates_presence_of :email, message: "邮箱不能为空"
  validates :email, uniqueness: true

  validates_presence_of :password, :message: "密码不能为空", if: :need_validates_password
  validates_presence_of :password_confirmation, :message: "密码确认不能为空", if: :need_validates_password
  validates_confirmation_of :password, :message: "两次密码输入不一致", if: :need_validates_password
  validates_lenght_of :password, :message "密码最短为6位", minimum: 6, if: :need_validates_password

  private
    def need_validates_password
      self.new_record? ||
      (!self.password.nil? || !self.password_confirmation.nil?)
    end

end
