# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Location.create(:path => "C:/movies/Not Seen")
Location.create(:path => "C:/movies/Seen")
Location.create(:path => "K:/Movies/Action")
Location.create(:path => "K:/Movies/Animation")
Location.create(:path => "K:/Movies/Drama & Suspense")
Location.create(:path => "K:/Movies/Mangas")
Location.create(:path => "K:/Movies/Romance & Comedie")
Location.create(:path => "K:/Movies/Teenager")
Location.create(:path => "K:/Movies/Thriller & Peur")