require "test_helper"

class AcademicToolsTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, full_name: "Student User")
    @teacher = create(:user, role: :teacher, full_name: "Professor User")
    @admin = create(:user, role: :admin, full_name: "Admin User")
    @subject = create(:subject, teacher: @teacher)

    # Enroll student
    create(:enrollment, user: @student, subject: @subject)
  end

  test "quiz system: teacher creates, student takes, teacher grades" do
    # 1. Teacher creates a quiz
    sign_in_as(@teacher)

    assert_difference "Quiz.count", 1 do
      post subject_quizzes_path(@subject), params: {
        quiz: {
          title: "Midterm Exam",
          due_at: 2.days.from_now.to_s,
          quiz_questions_attributes: [
            { question: "What is Ruby?", question_type: "mcq", choices: [ "A Language", "A Gem" ], points: 10 },
            { question: "Rails is written in Ruby.", question_type: "true_false", points: 15 }
          ]
        }
      }
    end

    quiz = Quiz.last
    assert_equal 25, quiz.total_points
    assert_equal 2, quiz.quiz_questions.count
    assert_redirected_to subject_quizzes_path(@subject)

    # 1.1. Check index page
    get subject_quizzes_path(@subject)
    assert_response :success
    assert_match "Midterm Exam", response.body

    # 2. Student takes the quiz
    sign_in_as(@student)
    get subject_quiz_path(@subject, quiz)
    assert_response :success

    q1, q2 = quiz.quiz_questions.order(:id).to_a
    assert_difference "QuizAnswer.count", 2 do
      post subject_quiz_quiz_answers_path(@subject, quiz), params: {
        answers: {
          q1.id => "A Language",
          q2.id => "True"
        }
      }
    end

    assert_redirected_to subject_quiz_path(@subject, quiz)
    follow_redirect!
    assert_match "submitted successfully", response.body

    # 3. Teacher grades the quiz
    sign_in_as(@teacher)
    get grade_subject_quiz_path(@subject, quiz)
    assert_response :success

    a1 = QuizAnswer.find_by(quiz_question: q1, user: @student)
    a2 = QuizAnswer.find_by(quiz_question: q2, user: @student)

    post grade_answers_subject_quiz_path(@subject, quiz), params: {
      grades: {
        a1.id => 9,
        a2.id => 14
      }
    }

    assert_redirected_to grade_subject_quiz_path(@subject, quiz)
    assert_equal 9, a1.reload.score
    assert_equal 14, a2.reload.score

    # Check validation that score cannot exceed question points
    post grade_answers_subject_quiz_path(@subject, quiz), params: {
      grades: {
        a1.id => 12 # exceeding max points (10)
      }
    }
    assert_redirected_to grade_subject_quiz_path(@subject, quiz)
    follow_redirect!
    assert_match "Failed to update grades", response.body

    # 4. Teacher edits the quiz
    sign_in_as(@teacher)
    get edit_subject_quiz_path(@subject, quiz)
    assert_response :success

    patch subject_quiz_path(@subject, quiz), params: {
      quiz: {
        title: "Midterm Exam Revised",
        due_at: 3.days.from_now.to_s,
        quiz_questions_attributes: [
          { id: q1.id, question: "What is Ruby programming language?", question_type: "mcq", choices: [ "A Language", "A Gem", "Both" ], points: 12 },
          { id: q2.id, question: "Rails is written in JavaScript?", question_type: "true_false", points: 8 }
        ]
      }
    }

    assert_redirected_to subject_quiz_path(@subject, quiz)
    quiz.reload
    assert_equal "Midterm Exam Revised", quiz.title
    assert_equal 20, quiz.total_points
    q1.reload
    assert_equal "mcq", q1.question_type
    assert_equal [ "A Language", "A Gem", "Both" ], q1.choices
    assert_equal 12, q1.points

    # 5. Teacher deletes the quiz
    assert_difference "Quiz.count", -1 do
      delete subject_quiz_path(@subject, quiz)
    end
    assert_redirected_to subject_quizzes_path(@subject)
  end

  test "schedules: teacher manages weekly timetable" do
    sign_in_as(@teacher)

    # Create schedule entry
    assert_difference "Schedule.count", 1 do
      post subject_schedules_path(@subject), params: {
        schedule: {
          day: 1, # Monday
          start_time: "09:00",
          end_time: "10:30",
          room: "Lecture Hall A"
        }
      }
    end

    schedule = Schedule.last
    assert_redirected_to subject_schedules_path(@subject)

    # Delete schedule entry
    assert_difference "Schedule.count", -1 do
      delete subject_schedule_path(@subject, schedule)
    end
    assert_redirected_to subject_schedules_path(@subject)
  end

  test "attendance: teacher records, student views dashboard" do
    # 1. Teacher records attendance
    sign_in_as(@teacher)
    get record_subject_attendances_path(@subject)
    assert_response :success

    # Record student as present today
    today = Date.current
    assert_difference "Attendance.count", 1 do
      post subject_attendances_path(@subject), params: {
        date: today.to_s,
        attendance: {
          @student.id => "present"
        }
      }
    end

    assert_redirected_to subject_attendances_path(@subject)

    # 2. Student views dashboard and rate is 100%
    sign_in_as(@student)
    get subject_attendances_path(@subject)
    assert_response :success
    assert_match "100.0%", response.body
  end

  test "assignments system: teacher creates, student submits, teacher grades" do
    # 1. Teacher creates an assignment with worksheet file
    sign_in_as(@teacher)

    worksheet = fixture_file_upload("test.pdf", "application/pdf")
    assert_difference "Assignment.count", 1 do
      post subject_assignments_path(@subject), params: {
        assignment: {
          title: "Lab Assignment 1",
          description: "Solve the problems in the attached worksheet.",
          due_at: 2.days.from_now.to_s,
          total_points: 100,
          file: worksheet
        }
      }
    end

    assignment = Assignment.last
    assert_equal "Lab Assignment 1", assignment.title
    assert assignment.file.attached?
    assert_redirected_to subject_assignments_path(@subject)

    # 1.1. Check index page
    get subject_assignments_path(@subject)
    assert_response :success
    assert_match "Lab Assignment 1", response.body

    # 2. Student submits assignment file
    sign_in_as(@student)
    get subject_assignment_path(@subject, assignment)
    assert_response :success
    assert_match "Download Worksheet", response.body

    student_solution = fixture_file_upload("test.pdf", "application/pdf")
    assert_difference "AssignmentSubmission.count", 1 do
      post subject_assignment_assignment_submissions_path(@subject, assignment), params: {
        assignment_submission: {
          file: student_solution
        }
      }
    end

    assert_redirected_to subject_assignment_path(@subject, assignment)
    follow_redirect!
    assert_match "submitted successfully", response.body
    assert_match "Download Solved File", response.body

    # 3. Teacher grades submission
    sign_in_as(@teacher)
    get grade_subject_assignment_path(@subject, assignment)
    assert_response :success
    assert_match "Download Solved File", response.body

    submission = AssignmentSubmission.last
    post grade_submissions_subject_assignment_path(@subject, assignment), params: {
      grades: {
        submission.id => 95
      },
      feedbacks: {
        submission.id => "Well done! Clean work."
      }
    }

    assert_redirected_to grade_subject_assignment_path(@subject, assignment)
    assert_equal 95, submission.reload.score
    assert_equal "Well done! Clean work.", submission.feedback

    # 4. Student views their score & feedback
    sign_in_as(@student)
    get subject_assignment_path(@subject, assignment)
    assert_response :success
    assert_match "95 / 100 pts", response.body
    assert_match "Well done! Clean work.", response.body

    # 5. Teacher edits assignment
    sign_in_as(@teacher)
    get edit_subject_assignment_path(@subject, assignment)
    assert_response :success

    patch subject_assignment_path(@subject, assignment), params: {
      assignment: {
        title: "Revised Lab Assignment 1",
        total_points: 90
      }
    }
    assert_redirected_to subject_assignment_path(@subject, assignment)
    assert_equal "Revised Lab Assignment 1", assignment.reload.title
    assert_equal 90, assignment.total_points

    # 6. Teacher deletes assignment
    assert_difference "Assignment.count", -1 do
      delete subject_assignment_path(@subject, assignment)
    end
    assert_redirected_to subject_assignments_path(@subject)
  end
end
