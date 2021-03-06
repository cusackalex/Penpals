get '/' do
  if session[:user_id]
    p "[LOG] you've routed to homepage view "
    @current_user = User.find(session[:user_id])
    erb :"/homepage/homepage"
  else
    p "[LOG] you've routed to sigup view"
    erb :'homepage/login_signup'
  end
end

post '/login' do
  p "[LOG] you've routed to homepage view"
  if @user = User.authenticate(params[:username], params[:password])
    session[:user_id] = @user.id
    p "[LOG] Authentication succeeded"
    redirect '/'
  else
    p "[LOG] Authentication failed"
    @errors = "be sure your username and password are correct"
    erb :'homepage/login_signup'
  end
end

post '/signup' do
  p "[LOG] you've routed to the SIGNUP post route"
  if params[:password] == params[:verify_password]
    p "[LOG] passwords match"
    new_user = User.new(username: params[:username], password: params[:password])
    if new_user.save
      p "[LOG] User saved"
      session[:user_id] = new_user.id
      redirect '/'
    else
      @errors = new_user.errors
      erb :"homepage/login_signup"
    end
  else
    p "[LOG] User not saved"
    @errors = ["Passwords need to match!"]
    erb :"homepage/login_signup"
  end
end

get '/logout' do
  session.delete(:user_id)
   erb :'homepage/login_signup'
end

post '/notes' do
  p "[LOG] you've reached POST /notes "
  p "[LOG] your params are: #{params.inspect}"
  new_note = Note.new(message: params[:message], user_id: session[:user_id])
  new_address = Receiver.new(params[:address])
  new_address.user_id = session[:user_id]
  if new_address.save && new_note.save
    p "[LOG] Note and address saved"
    redirect "notes/#{new_note.id}"
  else
    p "[LOG] Note and address NOT saved"
    @errors = "#{new_note.errors.messages}" + "#{new_address.errors.messages}"
    @current_user = User.find(session[:user_id])
    erb :"/homepage/homepage"
  end
end


get '/notes/:id' do
  p "[LOG] you've reached /notes/:id"
  p "[LOG] your params are: #{params.inspect}"
  @note = Note.find(params[:id])
  erb :"/note/note_confirmation"
end

delete '/delete/:note_id' do
  p "[LOG] hit delete route"
  p params.inspect
  note = Note.find(params[:note_id])
  note.destroy
  p "[LOG] exiting delete route"
  redirect "/profile/#{session[:user_id]}"
end

put '/updateaddress' do
  p "[LOG] hit address route"
 new_address = Receiver.where(user_id: session[:user_id]).first
  p "#{session[:user_id]}"
  p "#{new_address}"
 if new_address
  p "[LOG] address found"
  new_address.update_attributes(params[:address])
  redirect ("/profile/#{session[:user_id]}")
  else
  p "[LOG] Address was not found"
  redirect ("/profile/#{session[:user_id]}")
  end
end


get '/profile/:user_profile' do
  @current_user = User.find(params[:user_profile])
  p "[LOG] routed to /:user_profile"
  if @current_user && @current_user.id == session[:user_id]
    p "[LOG] user verifed as logged in user"
    @notes = @current_user.notes
    erb :"/profile/user_profile"
  else
    p "[LOG] user not authenticated to view profile"
  end
end
