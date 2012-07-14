# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Added By: Parth Barot, 10-July-2012
# Comment: Adding seed data for positions, departments and industries tables.

i=0
if Position.all.count == 0
  puts "Creating positions look up data..."
  Position.create(title: "Full time")
  Position.create(title: "Part time")
  Position.create(title: "Promotional")
  i+=1
end

if Department.all.count == 0
  puts "Creating departments look up data..."
  Department.create(title: "Sales")
  Department.create(title: "Marketing")
  Department.create(title: "Advertising")
  i+=1
end

if Industry.all.count == 0
  puts "Creating industries look up data..."
  Industry.create(title: "Media")
  Industry.create(title: "Information Technology")
  Industry.create(title: "Banking")
  Industry.create(title: "Insurance")
  i+=1
end

if i==0
  puts " =================> Seed data already exists, seed data is not updated <================= "
end
