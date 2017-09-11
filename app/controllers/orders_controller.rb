class OrdersController < ApplicationController

  before_action :auth_user

  def new
    fetch_home_data
    @shopping_carts = ShoppingCart.by_user_uuid(session[:user_uuid])
                      .order("id desc").includes([:product => [:main_product_image]])
  end

  def create
    shopping_carts = ShoppingCart.by_user_uuid(current_user.uuid).includes([:product => [:main_product_image]])
    if shopping_carts.blank?
      redirect_to shopping_carts_path
      return
    end
    # binding.pry
    address = current_user.addresses.find(params[:address_id])

    Order.create_order!(current_user, address, shopping_carts)

    redirect_to payments_path
  end

end
