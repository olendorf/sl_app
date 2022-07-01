class AddHoverTextColorToAbstractWebobject < ActiveRecord::Migration[6.1]
  def change
    add_column :abstract_web_objects, :hover_text_color, :string, default: "#ff0000"
  end
end
