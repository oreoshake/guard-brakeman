# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_default_app_session',
  :secret      => 'a9c9577f7beb302750c11b356e6a12d9a6c00450959bee2f6ab10dafd757de78623bdd432a11f504a8b56e74d44ef4a74162cab4633d728e17504848a33511d7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
