class AddRegionalIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :regional_master, :boolean
    add_index :posts, :regional_master
    add_column :posts, :master_id, :integer
    add_index :posts, :master_id

    Post.all.each do |post|
      id = post.id.to_s
      id_first = id[0]
      id_last = id[1..3]

      if id_last == "000"
        post.regional_master = true
        post.master_id = post.id
        post.save
        p [post.id, post.name, 'master']
        next
      end

      master_id = "#{id_first}000".to_i
      master = Post.find(master_id)
      unless master
        puts "ERROR FINDING MASTER: #{master_id}"
        next
      end
      post.master = master
      post.save
      p [post.id, post.name, master.name]
    end
  end

end
