
require 'ipaddr'

class Default::App
  before do
    # API requests can't handle form based authentication, and should be handled
    # separately.
    return if request.path =~ /^\/api/

    # Ensure the request is coming from a whitelisted network
    validate_network
    unless logged_in? || request.path =~ /^\/login/
      login_required
    end
  end

  enable :sessions

  get '/login/?' do
    if logged_in?
      flash[:notice] = "You're already logged in."
      redirect_to_stored
    else
      erb :"auth/login"
    end
  end

  post '/login/?' do
    if !logged_in? && user = User.authenticate(params["username"], params["password"])
      session[:user] = user.id
      session[:ip] = request.ip
      flash[:success] = "You've successfully logged in as #{user.username}."

      redirect_to_stored
    else
      flash.now[:alert] = "Invalid login credentials provided."
      erb :"auth/login"
    end
  end

  # Logs the user out, this route isn't available unless the user is logged in.
  get '/logout/?' do
    session[:user] = nil
    session[:ip] = nil

    flash[:notice] = "You've been logged out."
    redirect "/"
  end

  helpers do
    # Get a copy of the currently logged in user or nil if the user is
    # invalid/not logged in.
    #
    # @return [User,Nil]
    def current_user
      User.get(session[:user])
    end

    # Checks to see whether or not the current user is logged in, also checks to
    # ensure the user is still within a valid network, just in case that is
    # missed somewhere it's an extra layer of protection.
    #
    # @return [Boolean]
    def logged_in?
      (network_valid? && !!current_user && session[:ip] == request.ip)
    end

    # A helper method that allows sinatra to become aware of when an action
    # requires a login before proceeding. Will ensure the user logs in before
    # they are able to continue.
    def login_required
      return false if logged_in?

      flash[:alert] = "You need to login before continuing."
      session[:stored_path] = request.fullpath
      redirect "/login"
    end

    # Checks the address the request is coming from and ensures it's in our
    # approved network list.
    #
    # @return [Boolean]
    def network_valid?
      matched_nets = ['127.0.0.1', '::1'].map do |net|
        IPAddr.new(net).include?(request.ip)
      end
      matched_nets.include?(true)
    end

    # A helper method to redirect to the last page requested that required a
    # login. Makes the work flow of logging in smoother as you don't have to
    # re-navigate back to the page you were on. Will default to the root home
    # page if there isn't a stored path.
    def redirect_to_stored
      if new_loc = session[:stored_path]
        session[:stored_path] = nil
        redirect new_loc
      else
        redirect "/"
      end
    end

    # A helper to only display a forbidden page if you address has not been
    # pre-approved for access to the licensing server.
    def validate_network
      halt(403, erb(:"auth/forbidden")) unless network_valid?
    end
  end
end
