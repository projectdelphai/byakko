class UsersController < ApplicationController
  before_filter :user_entry_okay, only: [ :show ]
  def show
    @user = User.find(params[:id])
    @subscription = YAML.load(@user.subscription) unless @user.subscription == nil
    @newchapters=[]
    @subscription.each { |x|
      manga = Manga.find_by_title(x[:title])
      y = manga.latestchapter.to_i - x[:chapter].to_i
      @newchapters.push y
    }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Registration successful!"
      redirect_to @user
    else
      flash[:failed] = "Registration failed!"
      render 'new'
    end
  end

  private
  
  def user_entry_okay
    if signed_in?
      user = User.find(params[:id])
      if user.username == current_user.username
	nil
      else
	redirect_to current_user, notice: "Not signed in to proper user"
      end
    else
      redirect_to signin_url, notice: "Please sign in."
    end
  end
end
