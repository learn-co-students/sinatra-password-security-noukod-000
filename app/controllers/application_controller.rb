require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

	configure do
		set :views, "app/views"
		enable :sessions
		set :session_secret, "password_security"
	end

	get "/" do
		erb :index
	end

	get "/signup" do
		erb :signup
	end

	post "/signup" do
		#binding.pry
		#User.create(params)
		# but we need to implement more behavior
		user = User.new(:username => params[:username], :password => params[:password])
		if user.save
			# because of hash_secure_password
			# we won't be able to save empty password
	    redirect "/login"
	  else
	    redirect "/failure"
	  end
	end

	get "/login" do
		erb :login
	end

	post "/login" do
		#binding.pry
		#User.find_by_username(params[:username])
		user = User.find_by(:username => params[:username])
=begin
Let's step through the process of how `User`'s `authenticate` method works. It:

1. Takes a `String` as an argument e.g. `i_luv@byron_poodle_darling`
2. It turns the `String` into a salted, hashed version (`76776516e058d2bf187213df6917a7e`)
3. It compares this salted, hashed version with the user's stored salted,
	 hashed password in the database
4. If the two versions match, `authenticate` will return the `User` instance;
	 if not, it returns `false`

> **IMPORTANT** At no point do we look at an unencrypted version of the user's
> password.

In the code below, we see how we can ensure that we have a `User` AND that that
`User` is authenticated. If the user authenticates, we'll set the
`session[:user_id]` and redirect to the `/success` route. Otherwise, we'll
redirect to the `/failure` route so our user can try again.
=end
	if user && user.authenticate(params[:password])
		session[:user_id] = user.id
		redirect "/success"
	else
	 	redirect "/failure"
	end
end

	get "/success" do
		if logged_in?
			erb :success
		else
			redirect "/login"
		end
	end

	get "/failure" do
		erb :failure
	end

	get "/logout" do
		session.clear
		redirect "/"
	end

	helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end

end
