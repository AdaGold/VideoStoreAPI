require "test_helper"

describe MoviesController do
  describe "index" do

    it "should get index" do
      get movies_path
      must_respond_with :success
    end

    it "returns json" do
      get movies_path
      response.header['Content-Type'].must_include 'json'
    end

    it "returns an array" do
      get movies_path
      body = JSON.parse(response.body)
      body.must_be_kind_of Array
    end

    it "returns all of the movies" do
      get movies_path

      body = JSON.parse(response.body)
      body.length.must_equal Movie.count
    end

    it "returns movies with the required fields" do
      keys = %w(id release_date  title)
      get movies_path
      body = JSON.parse(response.body)
      body.each do |movie|
        movie.keys.sort.must_equal keys
      end
    end

    it "returns an empty array if there are no movies" do
      Movie.destroy_all
      get movies_path
      must_respond_with :success

      body = JSON.parse(response.body)
      body.must_be_kind_of Array
      body.must_equal []
    end
  end

  describe "show" do
    it "can get a movie" do
      get movie_path(movies(:two).id)
      must_respond_with :success
    end

    it "shows required fields in the movie show page" do
      keys = %w(available_inventory inventory overview release_date title)
      get movie_path(movies(:one).id)
      body = JSON.parse(response.body)
      body.keys.sort.must_equal keys
    end

    it "returns an error for invalid movie" do
      movies(:one).destroy()
      get movie_path(movies(:one).id)
      must_respond_with :not_found
    end
  end

  describe "create" do
    let(:movie_data) {
      {
        title: "a new movie",
        inventory: 5
      }
    }

    it "can create a movie when given valid required information" do
      assert_difference "Movie.count", 1 do
        post create_movie_path, params: { movie: movie_data}
      end

      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body.must_include "id"

      Movie.find(body["id"]).title.must_equal movie_data[:title]
    end

    it "returns an error for an invalid movie title" do
      bad_data = movie_data.clone()
      bad_data.delete(:title)
      assert_no_difference "Movie.count" do
        post create_movie_path, params: { movie: bad_data }
        assert_response :bad_request
      end

      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body.must_include "errors"
      body["errors"].must_include "title"
    end

    it "returns an error for an invalid movie title" do
      bad_data = movie_data.clone()
      bad_data.delete(:inventory)
      assert_no_difference "Movie.count" do
        post create_movie_path, params: { movie: bad_data }
        assert_response :bad_request
      end

      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body.must_include "errors"
      body["errors"].must_include "inventory"
    end
  end
end
