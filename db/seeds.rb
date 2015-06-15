# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'Create test User: '

user1 = User.create!(email: 'naim.cse07@gmail.com', password: '12345678', password_confirmation: '12345678')
puts "#{user1.email} has been created."
user2 = User.create!(email: 'naim_cse07@yahoo.com', password: '12345678', password_confirmation: '12345678')
puts "#{user2.email} has been created."

# puts 'Create test User Bank Account: '
user1 = User.find_by_email('naim.cse07@gmail.com')
user1.build_bank_account
user1.save!
user2 = User.find_by_email('naim_cse07@yahoo.com')
user2.build_bank_account
user2.save!