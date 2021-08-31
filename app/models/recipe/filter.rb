class Recipe::Filter
<<<<<<< HEAD
  def filter(scope, query_params)
    
=======
  def filter(scope, filters_params)
<<<<<<< HEAD
>>>>>>> af2d946 (Joined sorting and filtering)

=======
>>>>>>> 663e8e3 (Debugged searching recipes)
    if filters_params[:my_books] == "1" && filters_params[:current_user].present?
      scope = scope.joins(:cook_books).where(cook_books: {user_id: filters_params[:current_user]})
    end

    if filters_params[:difficulties].present?
      difficulties = filters_params[:difficulties].map(&:to_i)
      scope = scope.where("difficulty IN (?)", difficulties)
    end

    if filters_params[:categories].present?
      scope = scope.joins(:categories).where("categories.name IN (?)", filters_params[:categories])
    end

<<<<<<< HEAD
    if query_params[:ingredients].present?
      scope = scope.joins(:ingredients).where("ingredients.name IN (?)", query_params[:ingredients]).group(:id,:name).having("count(distinct ingredients.name) = ?",query_params[:ingredients].length)
=======
    if filters_params[:ingredients].present?
      scope = scope.joins(:ingredients).where("ingredients.name IN (?)", filters_params[:ingredients])
>>>>>>> af2d946 (Joined sorting and filtering)
    end

    if filters_params[:time].present?
      scope = case filters_params[:time]
      when "all"
        scope.all
      when "less_than_15_minutes"
        scope.where("time_in_minutes_needed < 15")
      when "less_than_30_minutes"
        scope.where("time_in_minutes_needed < 30")
      when "less_than_hour"
        scope.where("time_in_minutes_needed < 60")
      else
        scope.where("time_in_minutes_needed >= 60")
      end
    end

<<<<<<< HEAD
    if query_params[:text].present?
      scope = scope.where("LOWER(title) LIKE :text", text: "%#{query_params[:text].downcase}%")
=======
    if filters_params[:kind].present? && filters_params[:order].present?
      case filters_params[:kind]
      when "title", "difficulty", "time_in_minutes_needed"
        scope = scope.order(filters_params[:kind] => filters_params[:order])
      when "score"
        nulls_presence = filters_params[:order] == "DESC" ? "NULLS LAST" : "NULLS FIRST"
        scope = scope.left_outer_joins(:recipe_scores)
          .select("recipes.*")
          .group("recipes.id")
          .order("avg(recipe_scores.score) #{filters_params[:order]} #{nulls_presence}")
      end
>>>>>>> af2d946 (Joined sorting and filtering)
    end

    scope.distinct
  end
end
