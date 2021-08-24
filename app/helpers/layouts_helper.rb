module LayoutsHelper
  def btn_nav_class_for_recipes(path)
    request.path.include?(path) && request.path != new_recipe_path ? "btn-nav-active" : "btn-nav"
  end

  def btn_nav_class_overall(path)
    request.path.include?(path) ? "btn-nav-active" : "btn-nav"
  end
end
