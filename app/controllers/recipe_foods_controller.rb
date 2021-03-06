class RecipeFoodsController < ApplicationController
  load_and_authorize_resource :recipe
  load_and_authorize_resource :recipe_food, through: :recipe
  def shopping_list
    @recipe = Recipe.includes(:foods).find(params[:recipe_id])
    puts @recipe.total_price
    @foods = @recipe.foods
  end

  def new
    @current_user = current_user
    @foods = @current_user.foods
    @recipe_food = RecipeFood.new
  end

  def create
    @food = Food.find(params[:recipe_food][:food_id])
    @recipe = Recipe.find(params[:recipe_id])
    @recipe_food = RecipeFood.new(recipe_food_params)
    puts "price #{@recipe.total_price}"
    @food.update(quantity: params[:recipe_food][:quantity])
    @recipe_food.recipe = @recipe
    @recipe_food.food = @food
    respond_to do |format|
      if @recipe_food.save
        @recipe.update!(total_price: @recipe.total_price + (@food.price * @food.quantity))
        format.html { redirect_to recipe_url(@recipe), notice: 'Recipe Food added successfully.' }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe_food.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @recipe_food = RecipeFood.find(params[:id])
    @recipe = Recipe.find(params[:recipe_id])
    @food = Food.find(params[:food_id])
    @recipe_food.destroy
    @recipe.update(total_price: @recipe.total_price - (@food.price * @food.quantity))
    respond_to do |format|
      format.html { redirect_to recipe_url(id: params[:recipe_id]), notice: 'Recipe Food was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def recipe_food_params
    params.require(:recipe_food).permit(:quantity, :food_id, :recipe_id)
  end
end
