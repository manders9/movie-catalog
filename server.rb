require "sinatra"
require "sinatra/reloader"
require "pg"

def db_connection
	begin
		connection = PG.connect(dbname: 'movies')

		yield(connection)

	ensure
		connection.close
	end
end


def get_actors
	query = "SELECT actors.name AS actor, actors.id FROM actors ORDER BY name LIMIT 20"
	
	db_connection do |conn|
		actors = conn.exec(query)
	end
end

def get_actor_catalog
	actor_id = params[:id]
	query = "SELECT actors.name AS actor, movies.title AS movie, cast_members.character AS role FROM movies JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON cast_members.actor_id = actors.id WHERE actors.id = $1"

	db_connection do |conn|
		actor = conn.exec_params(query, [actor_id])
	end
end

def get_movies
	query = "SELECT movies.id AS movie_id, movies.title AS movie, movies.year, movies.rating, genres.name AS genre, studios.name AS studio FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id ORDER BY movies.title LIMIT 20"

	db_connection do |conn|
		movies_table = conn.exec(query)
	end
end

get "/actors" do
	@actors = get_actors

	erb :"/actors/index"
end

get "/actors/:id" do
	@actor = get_actor_catalog

	erb :"/actors/show"
end


get "/movies" do
	@movies = get_movies

	erb :"/movies/index"
end

# get "/movies/:id"

# 	erb :"/movies/show"
# end