# frozen_string_literal: true

class RecipesController < ApplicationController
  DEFAULT_SORT_KIND = "title"
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:update, :update_favourite, :update_cook_books, :show, :edit, :destroy]

  def index
    params = filters_params
    if current_user
      params[:current_user] = current_user
    end
    set_filters_variables(params)
    recipes = Recipe.published.filtered_and_sorted(params)
    @pagy, @recipes = pagy(recipes, items: per_page)
  end

  def show
    @recipe = Recipe.find_by(id: params[:id])
    if @recipe.draft? && @recipe.user != current_user
      respond_to do |format|
        format.html { redirect_to recipes_path, notice: t(".warning") }
      end
    else
      @ingredients_recipe = @recipe.ingredients_recipes
      gon.avgScore = @recipe.average_score
    end
  end

  def new
    @recipe = Recipe.new
    @ingredients = []
  end

  def edit
    @recipe = Recipe.find_by(id: params[:id])
    if @recipe.draft? && @recipe.user != current_user
      respond_to do |format|
        format.html { redirect_to recipes_path, notice: t(".warning") }
      end
    else
      set_ingredients
    end
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user
    @recipe.resize_image if params[:recipe].key?(:image)
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: t(".notice") }
      else
        @recipe.errors.full_messages.each do |e|
          flash.now[:error] = e
        end
        @ingredients = []
        if recipe_params.has_key?(:ingredients_recipes_attributes)
          recipe_params[:ingredients_recipes_attributes].values.each do |i|
            if i[:_destroy] != 1
              @ingredients.append(i.except(:_destroy))
            end
          end
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy if @recipe.user == current_user || current_user.admin?
    respond_to do |format|
      format.html { redirect_to recipes_path, notice: t(".notice") }
    end
  end

  def update
    params = recipe_params
    if !params.key?(:category_ids)
      params[:category_ids] = []
    end
    if !params.key?(:ingredients_recipes_attributes)
      IngredientsRecipe.where(recipe_id: @recipe.id).destroy_all
      params[:ingredients_recipes_attributes] = {}
    end
    @recipe.attributes = params
    @recipe.resize_image if params.key?(:image)
    respond_to do |format|
      if @recipe.valid? && params[:ingredients_recipes_attributes] != {}
        IngredientsRecipe.where(recipe_id: @recipe.id).destroy_all
        @recipe.save
        format.html { redirect_to @recipe, notice: t(".notice") }
      else
        set_ingredients
        @recipe.errors.full_messages.each do |e|
          flash.now[:error] = e
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update_cook_books
    if @recipe.cook_books_update(cook_books_params[:cook_book_ids], current_user)
      flash[:notice] = t(".notice")
    else
      flash[:alert] = t(".alert")
    end
    redirect_back(fallback_location: recipes_path)
  end

  def update_favourite
    @recipe.toggle_favourite(current_user)
    flash[:notice] = t(".notice")
    redirect_to(@recipe)
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:image, :title, :preparation_description, :time_in_minutes_needed, :difficulty, :user_id, :status, :layout, category_ids: [],
      ingredients_recipes_attributes: [:id, :ingredient_name, :quantity, :unit, :_destroy])
  end

  def cook_books_params
    params.require(:recipe).permit(cook_book_ids: [])
  end

  def set_ingredients
    @ingredients = []
    IngredientsRecipe.where("recipe_id=#{@recipe.id}").each do |i|
      j = {ingredient_name: i.ingredient.name, quantity: i.quantity, unit: IngredientsRecipe.units[i.unit]}
      @ingredients.append(j)
    end
  end

  def filters_params
    filters_params = params[:filters]
    filters_params ? filters_params.permit(:search, :my_books, :kind, :order, :time, difficulties: [], categories: [], ingredients: []) : {}
  end

  def set_filters_variables(params)
    @search_text = params[:search].present? ? params[:search] : ""
    @sort_order = params[:order].present? ? params[:order] : "ASC"
    @sort_kind = params[:kind].present? ? params[:kind] : "title"
    @my_books = params[:my_books].present? ? params[:my_books] : "0"
    @time = params[:time].present? ? params[:time] : "all"
    @difficulties = params[:difficulties].present? ? params[:difficulties] : []
    @categories = params[:categories].present? ? params[:categories] : []
    @ingredients = params[:ingredients].present? ? params[:ingredients] : []
  end
end
