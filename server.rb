require "sinatra"
require "sinatra/reloader"
require "pg"

def db_connection
	begin
		connection = PG.connect(dbname: "movies")

		yield(connection)

	ensure
		connection.close
	end
end


def get_actors
	query = "SELECT actors.name AS actor, actors.id AS actor_id FROM actors ORDER BY name"
	
	db_connection do |conn|
		actors = conn.exec(query)
	end
end

def get_actor_catalog(query, actor_id)

	db_connection do |conn|
		actor_catalog = conn.exec_params(query, [actor_id])
	end
end

def get_movies
	query = "SELECT movies.id AS movie_id, movies.title AS movie, movies.year, movies.rating, genres.name AS genre, studios.name AS studio FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id ORDER BY movies.title"

	db_connection do |conn|
		movies = conn.exec(query)
	end
end

def get_movie_details(query, movie_id)

	db_connection do |conn|
		movie_details = conn.exec_params(query, [movie_id])
	end
end

get "/actors" do
	@actors = get_actors

	erb :"/actors/index"
end

get "/actors/:id" do
	query = "SELECT actors.name AS actor, movies.title AS movie, movies.id as movie_id, cast_members.character AS role FROM movies JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON cast_members.actor_id = actors.id WHERE actors.id = $1"
	actor_id = params[:id]
	@actor = get_actor_catalog(query, actor_id)

	erb :"/actors/show"
end


get "/movies" do
	@movies = get_movies

	erb :"/movies/index"
end

get "/movies/:id" do
	movie_id = params[:id]
	query = "SELECT movies.id AS movie_id, movies.title AS movie, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, actors.name AS actor, actors.id AS actor_id, cast_members.character AS role FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON cast_members.actor_id = actors.id WHERE movies.id = $1"
	@info = get_movie_details(query, movie_id)

	erb :"/movies/show"
end
