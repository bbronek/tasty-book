require "rails_helper"

RSpec.describe "profile/recipe_drafts", type: :view do
  include Pagy::Backend
  let(:user) { create(:user) }

  context "when user is not signed in" do
    before { visit recipe_drafts_profile_index_path }

    it { expect(current_path).to eql(new_user_session_path) }
  end

  context "when user hasn't created any recipes yet" do
    before do
      @pagy, @recipes = pagy_array(user.recipes.drafted, items: 12)
      assign(:recipes, @recipes)
      assign(:pagy, @pagy)
      visit user_session_path
      fill_in_and_log_in(user.email, user.password)
      visit recipe_drafts_profile_index_path
      render
    end

    it { expect(current_path).to eql(recipe_drafts_profile_index_path) }
    it { expect(rendered).to have_tag("a.current", text: t("profile.sidebar.recipe_drafts")) }
    it { expect(rendered).to have_tag("a.btn-secondary", text: t("recipes.create.action")) }
    it { expect(rendered).to have_text(t("recipes.not_found")) }
    it { expect(rendered).not_to have_tag("nav.pagy-nav") }
  end

  context "when user has draft recipes and pagy display 12 items per page" do
    before do
      10.times { |n| n % 2 == 0 ? create(:recipe, status: :draft) : create(:recipe, user: user, status: :draft) }
      create_list(:recipe, 3, user: user, status: :published)
      @pagy, @recipes = pagy_array(user.recipes.drafted, items: 12)
      assign(:recipes, @recipes)
      assign(:pagy, @pagy)
      visit user_session_path
      fill_in_and_log_in(user.email, user.password)
      visit recipe_drafts_profile_index_path
      render
    end

    it { expect(rendered).to have_tag("a.btn-secondary", text: t("recipes.create.action")) }
    it { expect(rendered).not_to have_text(t("recipes.not_found")) }
    it { expect(rendered).not_to have_tag("nav.pagy-nav") }
    it { expect(rendered).to have_tag("article.recipe") { with_tag("img", count: 5) } }
  end

  context "when user has 15 draft recipes and pagy display 12 items per page" do
    before do
      30.times { |n| n % 2 == 0 ? create(:recipe, status: :draft) : create(:recipe, user: user, status: :draft) }
      @pagy, @recipes = pagy_array(user.recipes.drafted, items: 12)
      assign(:recipes, @recipes)
      assign(:pagy, @pagy)
      visit user_session_path
      fill_in_and_log_in(user.email, user.password)
      visit recipe_drafts_profile_index_path
      render
    end

    it { expect(rendered).to have_tag("article.recipe") { with_tag("img", count: 12) } }
    it "displays a pagination navbar" do
      expect(rendered).to have_tag("nav.pagy-nav") do
        with_tag("span.prev", with: {class: "disabled"})
        with_tag("span.next", without: {class: "disabled"})
        with_tag("span.active", text: "1")
        with_tag("span", text: "2")
        without_tag("span", text: "3")
      end
    end
  end
end
