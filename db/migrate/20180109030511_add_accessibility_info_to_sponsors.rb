class AddAccessibilityInfoToSponsors < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :accessibility_info, :text
  end
end
