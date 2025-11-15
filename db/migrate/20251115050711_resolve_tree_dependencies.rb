class ResolveTreeDependencies < ActiveRecord::Migration[8.1]
  def change

    remove_reference :gifts, :user, foreign_key: true
    add_reference :gifts, :gift_list, foreign_key: true
  end
end
