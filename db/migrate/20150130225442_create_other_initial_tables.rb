class CreateOtherInitialTables < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :title
      t.string :content
      t.timestamps
    end
    create_table :images do |t|
      t.integer :post_id
      t.string :src
      t.timestamps
    end
    create_table :comments do |t|
      t.integer :post_id
      t.integer :user_id
      t.integer :comment_id
      t.string :message
      t.timestamps
    end
  end
end
