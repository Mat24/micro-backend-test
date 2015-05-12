class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_hash, null: false
      t.string :nombre
      t.string :apellido
      t.string :telefono
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :users
  end
end
