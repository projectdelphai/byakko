class UsersController < ApplicationController
  before_filter :api_key_login
  before_filter :user_entry_okay, only: [ :show ]
  after_filter :api_key_logout

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
      user = User.find(params[:id]).destroy
      redirect_to root_url
  end

  def show
    @newchapters = new_chapters(current_user)
    expires_in 180.minutes

    respond_to do |format|
      format.html
      format.json {
	manga=[]
	@newchapters.each { |x|
	    entry = { "title" => x[:title], "currentchapter" => x[:chapter], "newchapters" => x[:newchapter] }
	    manga.push entry
	}
    	expires_in 180.minutes
	render json: { "manga" => manga }
      }
    end
  end

  private

  def new_chapters(current_user)
    subscription = current_user.json_subscription unless current_user.subscription == nil
    number_of_new_chapters = check_for_number_of_new_chapters(subscription)
    unsorted_new_chapters = get_raw_new_chapters_info(subscription,number_of_new_chapters)
    @newchapters = unsorted_new_chapters.sort_by { |x| [-x[:newchapter], x[:title]] }
  end

  def get_raw_new_chapters_info(subscription,number_of_new_chapters)
    newchapters = []
    subscription.each_with_index { |manga,index|
      hash = { :title => manga[:title], :chapter => manga[:chapter], :newchapter => number_of_new_chapters[index] }
      newchapters.push hash
    }
    return newchapters
  end

  def check_for_number_of_new_chapters(subscription)
    number_of_new_chapters = []
    unless subscription == nil
      subscription.each { |manga|
	manga_record = Manga.find_by_title(manga[:title])
	number_of_new_chapters.push manga_record.latestchapter.to_i - manga[:chapter].to_i
      }
    end
    return number_of_new_chapters
  end

  def user_entry_okay
    if signed_in?
      redirect_to current_user, notice: "Not signed in to proper user" if User.find(params[:id]).username != current_user.username
    else
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def api_key_login
    sign_in(User.find_by_api_key(params['api_key'])) if params['api_key']
  end

  def api_key_logout
    sign_out if params['api_key']
  end

end
