# Comprehensive seed data for development/demo
# Run with: bin/rails db:seed
#
# Idempotent: this file wipes all rows from the tables below and re-creates
# the demo dataset, so re-running bin/rails db:seed is safe.

abort("Seeds are only allowed in development, test, and demo environments.") unless Rails.env.development? || Rails.env.test? || Rails.env.demo?

default_password = "password123"

puts "Cleaning existing data..."
ActiveStorage::Attachment.delete_all
ActiveStorage::Blob.delete_all
Message.delete_all
ChatParticipant.delete_all
TaskDistribution.delete_all
ChatRoom.delete_all
Material.delete_all
AuditLog.delete_all
Comment.delete_all
PostView.delete_all
QuizAnswer.delete_all
QuizQuestion.delete_all
Quiz.delete_all
AssignmentSubmission.delete_all
Assignment.delete_all
Attendance.delete_all
Schedule.delete_all
Notification.delete_all
Post.delete_all
Enrollment.delete_all
Subject.delete_all
Department.delete_all
College.delete_all
Session.delete_all
User.delete_all

puts "Creating users..."

admin = User.create!(
  full_name: "Admin User",
  email_address: "admin@morafeq.edu",
  password: default_password,
  role: :admin
)

teacher1 = User.create!(
  full_name: "Dr. Ahmed Hassan",
  email_address: "ahmed@morafeq.edu",
  password: default_password,
  role: :teacher
)

teacher2 = User.create!(
  full_name: "Dr. Sara Ali",
  email_address: "sara@morafeq.edu",
  password: default_password,
  role: :teacher
)

teacher3 = User.create!(
  full_name: "Dr. Khaled Omar",
  email_address: "khaled@morafeq.edu",
  password: default_password,
  role: :teacher
)

student1 = User.create!(
  full_name: "Omar Youssef",
  email_address: "omar@morafeq.edu",
  password: default_password,
  role: :student
)

student2 = User.create!(
  full_name: "Layla Mahmoud",
  email_address: "layla@morafeq.edu",
  password: default_password,
  role: :student
)

student3 = User.create!(
  full_name: "Yassin Nour",
  email_address: "yassin@morafeq.edu",
  password: default_password,
  role: :student
)

student4 = User.create!(
  full_name: "Nadia Ibrahim",
  email_address: "nadia@morafeq.edu",
  password: default_password,
  role: :student
)

moderator = User.create!(
  full_name: "Moderator User",
  email_address: "moderator@morafeq.edu",
  password: default_password,
  role: :moderator
)

ta = User.create!(
  full_name: "TA User",
  email_address: "ta@morafeq.edu",
  password: default_password,
  role: :teaching_assistant
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
  "EN101" => { name: "Introduction to Poetry", department: literature, teacher: teacher1 }
}

subjects = subject_data.map do |code, attrs|
  Subject.create!(name: attrs[:name], code: code, department: attrs[:department], teacher: attrs[:teacher])
end

puts "Creating enrollments..."

# Enroll all students and TA in core CS subjects
[ student1, student2, student3, student4, ta ].each do |user|
  Enrollment.create!(user: user, subject: subjects.find { |s| s.code == "CS101" })
  Enrollment.create!(user: user, subject: subjects.find { |s| s.code == "CS201" })
end

# Specialized enrollments
Enrollment.create!(user: student1, subject: subjects.find { |s| s.code == "CS301" })
Enrollment.create!(user: student2, subject: subjects.find { |s| s.code == "CS301" })
Enrollment.create!(user: student3, subject: subjects.find { |s| s.code == "ME101" })
Enrollment.create!(user: student4, subject: subjects.find { |s| s.code == "ME101" })
Enrollment.create!(user: student1, subject: subjects.find { |s| s.code == "PH101" })
Enrollment.create!(user: student2, subject: subjects.find { |s| s.code == "CH101" })
Enrollment.create!(user: student3, subject: subjects.find { |s| s.code == "EN101" })

puts "Creating demo posts..."

cs101 = subjects.find { |s| s.code == "CS101" }
cs201 = subjects.find { |s| s.code == "CS201" }
engineering_college = engineering

Post.create!(content: "Welcome to Introduction to Programming! Check the syllabus in Materials.", author: teacher1, scope: cs101, pinned: true)
Post.create!(content: "Reminder: Assignment 1 is due next Sunday.", author: teacher1, scope: cs101)
Post.create!(content: "Office hours this week: Tuesday 2-4 PM.", author: teacher1, scope: cs, scope_type: "Department", scope_id: cs.id)
Post.create!(content: "Engineering hackathon next month! Teams of 3-4.", author: teacher1, scope: engineering_college, scope_type: "College", scope_id: engineering_college.id, pinned: true)
Post.create!(content: "Data Structures midterm will cover trees and graphs.", author: teacher1, scope: cs201)

puts "  #{Post.count} posts (#{Post.where(pinned: true).count} pinned)"

puts "Creating demo materials..."

[ "CS101 Syllabus", "Assignment 1", "Lecture Slides - Week 1" ].each do |title|
  material = Material.new(title: title, subject: cs101)
  material.file.attach(io: StringIO.new("Demo content"), filename: "#{title.parameterize}.pdf", content_type: "application/pdf")
  material.save!
end

puts "  #{Material.count} materials"

puts "Creating demo messages..."

cs101_room = ChatRoom.find_by(subject: cs101)
if cs101_room
  Message.create!(content: "Welcome to the CS101 chat room!", user: teacher1, chat_room: cs101_room)
  Message.create!(content: "Does anyone know when Assignment 1 is due?", user: student1, chat_room: cs101_room)
  Message.create!(content: "Next Sunday as posted in the feed.", user: teacher1, chat_room: cs101_room)
  Message.create!(content: "Thanks Dr. Ahmed!", user: student2, chat_room: cs101_room)
end

puts "  #{Message.count} messages"

puts ""
puts "Seeding complete!"
puts "  #{User.count} users (#{User.student.count} students, #{User.teacher.count} teachers, #{User.admin.count} admins, #{User.moderator.count} moderators, #{User.teaching_assistant.count} TAs)"
puts "  #{College.count} colleges"
puts "  #{Department.count} departments"
puts "  #{Subject.count} subjects"
puts "  #{ChatRoom.count} chat rooms"
puts "  #{Enrollment.count} enrollments"
puts "  #{Post.count} posts (#{Post.where(pinned: true).count} pinned)"
