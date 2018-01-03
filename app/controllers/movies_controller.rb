class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def filter
    
  end

  def index
    @all_ratings = ['G','PG','PG-13','R']
    @selected_ratings = {"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"}

    # Set visible ratings, default all
    if params[:ratings].present?
      @selected_ratings = params[:ratings]
    elsif session[:ratings].present?
      @selected_ratings = session[:ratings]
    end
    session[:ratings] = @selected_ratings

    # Set sort column, default id
    if params[:sort].present?
      @sort_column = params[:sort]
    elsif session[:sort].present?
      @sort_column = session[:sort]
    else
      @sort_column = "id"
    end
    session[:sort] = @sort_column

    # Redirect to maintain REST
    if !(params[:sort].present? && params[:ratings].present?)
      flash.keep
      redirect_to movies_path(sort: session[:sort], ratings: session[:ratings], utf8: "✓")
      return
    end

    # Get required data from database
    request = ""
    @selected_ratings.each do |key, value|
      request << "rating = '#{key}' OR "
    end
    request = request.chomp(" OR ")
    @movies = Movie.where(request).order("#{@sort_column} ASC")
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
