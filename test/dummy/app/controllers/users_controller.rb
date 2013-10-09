class UsersController < ApplicationController
  authorize_resource params: :user_params

  # GET /users
  def index
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :password)
    end
end
