class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :experience
      t.string :ideas
      t.integer :rating
      t.string :help
      t.references :user, index: true
      t.references :office, index: true

      t.timestamps null: false
    end
    add_foreign_key :feedbacks, :users
    add_foreign_key :feedbacks, :offices
  end
end
