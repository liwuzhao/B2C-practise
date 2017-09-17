class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password, :password_confirmation, :token

  CELLPHONE_RE = /\A(\+86|86)?1\d{10}\z/
  EMAIL_RE = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/

  validate :validate_email_or_cellphone, on: :create


  validates_presence_of :password, message: "密码不能为空", if: :need_validates_password
  validates_presence_of :password_confirmation, message: "密码确认不能为空", if: :need_validates_password
  validates_confirmation_of :password, message: "两次密码输入不一致", if: :need_validates_password
  validates_length_of :password, message: "密码最短为6位", minimum: 6, if: :need_validates_password

  def username
    self.email.blank? ? self.cellphone : self.email.split('@').first
  end

  has_many :addresses, -> { where(addresses_type: Address::AddressType::User) }
  belongs_to :default_address, class_name: :Address

  has_many :orders

  private
    def need_validates_password
      self.new_record? ||
      (!self.password.nil? || !self.password_confirmation.nil?)
    end

    def validate_email_or_cellphone
      #邮箱、手机号都为空
      if [self.email, self.cellphone].all? { |attr| attr.nil?}
        self.errors.add :base, "邮箱和手机号其中之一不能为空"
        return false
      else
        #使用邮箱注册
        if self.cellphone.nil?
          #邮箱为空
          if self.email.blank?
            self.errors.add :email, "邮箱不能为空"
            return false
          else
            #邮箱格式错误
            unless self.email =~ EMAIL_RE
              self.errors.add :email, "邮箱格式不正确"
              return false
            end
          end
          #邮箱重复
          if User.find_by email: self.email
            self.errors.add :email, "邮箱已被注册"
            return false
          end
        #使用手机号注册
        else
          if self.cellphone.blank?
            self.errors.add :cellphone, "手机号不能为空"
            return false
          else
            unless self.cellphone =~ CELLPHONE_RE
              self.errors.add :cellphone, "手机号格式不正确"
              return false
            end
          end
          #手机号重复
          if User.find_by cellphone: self.cellphone
            self.errors.add :email, "手机号已被注册"
            return false
          end
          #验证码错误
          unless VerifyToken.available.find_by(cellphone: self.cellphone, token: self.token)
            self.errors.add :cellphone, "手机验证码不正确或过期"
            return false
          end
        end

        return true
      end
    end
end
