class UsersController < ApplicationController
  before_filter :api_key_login
  before_filter :user_entry_okay, only: [ :show ]
  after_filter :api_key_logout

  def show
    bt=Time.now
    @user = User.find(params[:id])
    @subscription = YAML.load(@user.subscription) unless @user.subscription == nil
    @new=[]
    unless @subscription == nil
      @subscription.each { |x|
  	manga = Manga.find_by_title(x[:title])
  	y = manga.latestchapter.to_i - x[:chapter].to_i
  	@new.push y
      }
    end
    @newchapters=[]
    @subscription.each_with_index { |x,index|
      hash = { :title => x[:title], :chapter => x[:chapter], :newchapter => @new[index] }
      @newchapters.push hash
    }
    @newchapters = @newchapters.sort { |a,b| a[:newchapter] == b[:newchapter] ? a[:title] <=> b[:title] : a[:newchapter] <=> b[:newchapter] }.reverse
    respond_to do |format|
      format.html
      format.json {
	manga=[]
	@newchapters.each { |x|
	    entry = { "title" => x[:title], "currentchapter" => x[:chapter], "newchapters" => x[:newchapter] }
	    manga.push entry
	}
	puts manga
	render json: { "manga" => manga }
      }
    end
    et=Time.now
    puts et-bt

  end

  def new
    @user = User.new
  end

  def create
    params[:user].merge! :api_key => SecureRandom.hex
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

  def destroy
    if User.find(params[:id]).api_key == current_user.api_key
      user = User.find(params[:id]).destroy
      redirect_to root_url
    else
      redirect_to root_url
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

  def api_key_login
    if params['api_key']
      sign_in(User.find_by_api_key(params['api_key']))
    end
  end

  def api_key_logout
    if params['api_key']
      sign_out
    end
  end

end
