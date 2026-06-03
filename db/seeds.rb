# Comprehensive seed data for development/demo
# Run with: bin/rails db:seed

puts "Cleaning existing data..."
Enrollment.delete_all
Subject.delete_all
Department.delete_all
College.delete_all
User.delete_all

puts "Creating users..."

admin = User.create!(
  full_name: "Admin User",
  email_address: "admin@morafeq.edu",
  password: "password123",
  role: :admin
)

teacher1 = User.create!(
  full_name: "Dr. Ahmed Hassan",
  email_address: "ahmed@morafeq.edu",
  password: "password123",
  role: :teacher
)

teacher2 = User.create!(
  full_name: "Dr. Sara Ali",
  email_address: "sara@morafeq.edu",
  password: "password123",
  role: :teacher
)

teacher3 = User.create!(
  full_name: "Dr. Khaled Omar",
  email_address: "khaled@morafeq.edu",
  password: "password123",
  role: :teacher
)

student1 = User.create!(
  full_name: "Omar Youssef",
  email_address: "omar@morafeq.edu",
  password: "password123",
  role: :student
)

student2 = User.create!(
  full_name: "Layla Mahmoud",
  email_address: "layla@morafeq.edu",
  password: "password123",
  role: :student
)

student3 = User.create!(
  full_name: "Yassin Nour",
  email_address: "yassin@morafeq.edu",
  password: "password123",
  role: :student
)

student4 = User.create!(
  full_name: "Nadia Ibrahim",
  email_address: "nadia@morafeq.edu",
  password: "password123",
  role: :student
)

students = [ student1, student2, student3, student4 ]
teachers = [ teacher1, teacher2, teacher3 ]

puts "Creating colleges..."

engineering = College.create!(name: "Faculty of Engineering")
science = College.create!(name: "Faculty of Science")
arts = College.create!(name: "Faculty of Arts")

puts "Creating departments..."

cs = Department.create!(name: "Computer Science", college: engineering)
mech = Department.create!(name: "Mechanical Engineering", college: engineering)
physics = Department.create!(name: "Physics", college: science)
chemistry = Department.create!(name: "Chemistry", college: science)
literature = Department.create!(name: "English Literature", college: arts)

puts "Creating subjects..."

subject_data = {
  "CS101" => { name: "Introduction to Programming", department: cs, teacher: teacher1 },
  "CS201" => { name: "Data Structures", department: cs, teacher: teacher1 },
  "CS301" => { name: "Database Systems", department: cs, teacher: teacher2 },
  "ME101" => { name: "Engineering Mechanics", department: mech, teacher: teacher2 },
  "ME201" => { name: "Thermodynamics", department: mech, teacher: teacher3 },
  "PH101" => { name: "Classical Mechanics", department: physics, teacher: teacher3 },
  "PH201" => { name: "Electromagnetism", department: physics, teacher: teacher3 },
  "CH101" => { name: "General Chemistry", department: chemistry, teacher: teacher2 },
  "EN101" => { name: "Introduction to Poetry", department: literature, teacher: teacher1 },
}

subjects = subject_data.map do |code, attrs|
  Subject.create!(name: attrs[:name], code: code, department: attrs[:department], teacher: attrs[:teacher])
end

puts "Creating enrollments..."

# Enroll all students in core CS subjects
[ student1, student2, student3, student4 ].each do |student|
  Enrollment.create!(user: student, subject: subjects.find { |s| s.code == "CS101" })
  Enrollment.create!(user: student, subject: subjects.find { |s| s.code == "CS201" })
end

# Specialized enrollments
Enrollment.create!(user: student1, subject: subjects.find { |s| s.code == "CS301" })
Enrollment.create!(user: student2, subject: subjects.find { |s| s.code == "CS301" })
Enrollment.create!(user: student3, subject: subjects.find { |s| s.code == "ME101" })
Enrollment.create!(user: student4, subject: subjects.find { |s| s.code == "ME101" })
Enrollment.create!(user: student1, subject: subjects.find { |s| s.code == "PH101" })
Enrollment.create!(user: student2, subject: subjects.find { |s| s.code == "CH101" })
Enrollment.create!(user: student3, subject: subjects.find { |s| s.code == "EN101" })

puts "Seeding complete!"
puts "  #{User.count} users (#{User.student.count} students, #{User.teacher.count} teachers, #{User.admin.count} admins)"
puts "  #{College.count} colleges"
puts "  #{Department.count} departments"
puts "  #{Subject.count} subjects"
puts "  #{Enrollment.count} enrollments"
