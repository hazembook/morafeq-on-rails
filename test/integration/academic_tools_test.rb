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
            { question: "What is Ruby?", points: 10 },
            { question: "Explain Rails MVC.", points: 15 }
          ]
        }
      }
    end

    quiz = Quiz.last
    assert_equal 25, quiz.total_points
    assert_equal 2, quiz.quiz_questions.count
    assert_redirected_to subject_path(@subject)

    # 2. Student takes the quiz
    sign_in_as(@student)
    get subject_quiz_path(@subject, quiz)
    assert_response :success

    q1, q2 = quiz.quiz_questions.to_a
    assert_difference "QuizAnswer.count", 2 do
      post subject_quiz_quiz_answers_path(@subject, quiz), params: {
        answers: {
          q1.id => "Ruby is a dynamic, open source programming language.",
          q2.id => "MVC stands for Model-View-Controller."
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
  end

  test "quiz system with diverse question types: MCQ, True/False, Match, Written" do
    sign_in_as(@teacher)

    # 1. Teacher creates a quiz with multiple question types
    assert_difference "Quiz.count", 1 do
      post subject_quizzes_path(@subject), params: {
        quiz: {
          title: "Comprehensive Quiz",
          due_at: 2.days.from_now.to_s,
          quiz_questions_attributes: [
            { question: "What is Ruby?", question_type: "mcq", choices_text: "A Gem\nA Language\nA Mineral", points: 5 },
            { question: "Rails is written in Ruby.", question_type: "true_false", points: 5 },
            { question: "Match Capitals", question_type: "match", choices_text: "France: Paris\nSpain: Madrid", points: 10 },
            { question: "Explain ActiveRecord.", question_type: "written", points: 10 }
          ]
        }
      }
    end

    quiz = Quiz.last
    assert_equal 4, quiz.quiz_questions.count
    assert_equal 30, quiz.total_points

    q_mcq, q_tf, q_match, q_written = quiz.quiz_questions.order(:id).to_a
    assert_equal "mcq", q_mcq.question_type
    assert_equal [ "A Gem", "A Language", "A Mineral" ], q_mcq.choices
    assert_equal "true_false", q_tf.question_type
    assert_equal [ "True", "False" ], q_tf.choices
    assert_equal "match", q_match.question_type
    assert_equal({ "France" => "Paris", "Spain" => "Madrid" }, q_match.choices)
    assert_equal "written", q_written.question_type

    # 2. Student takes the quiz
    sign_in_as(@student)
    get subject_quiz_path(@subject, quiz)
    assert_response :success

    # Submit diverse answer types
    assert_difference "QuizAnswer.count", 4 do
      post subject_quiz_quiz_answers_path(@subject, quiz), params: {
        answers: {
          q_mcq.id.to_s => "A Language",
          q_tf.id.to_s => "True",
          q_match.id.to_s => {
            "France" => "Paris",
            "Spain" => "Madrid"
          },
          q_written.id.to_s => "ActiveRecord is an ORM framework."
        }
      }
    end

    assert_redirected_to subject_quiz_path(@subject, quiz)
    follow_redirect!
    assert_match "submitted successfully", response.body

    # Check that formatted answers are displayed correctly
    # Match display should render matched keys and values
    assert_match "France", response.body
    assert_match "Paris", response.body
    assert_match "Spain", response.body
    assert_match "Madrid", response.body

    # 3. Teacher grades the quiz
    sign_in_as(@teacher)
    get grade_subject_quiz_path(@subject, quiz)
    assert_response :success

    a_mcq = QuizAnswer.find_by(quiz_question: q_mcq, user: @student)
    a_tf = QuizAnswer.find_by(quiz_question: q_tf, user: @student)
    a_match = QuizAnswer.find_by(quiz_question: q_match, user: @student)
    a_written = QuizAnswer.find_by(quiz_question: q_written, user: @student)

    # Verify matching answer is stored as JSON string
    assert_equal({ "France" => "Paris", "Spain" => "Madrid" }.to_json, a_match.answer)

    # Update grades
    post grade_answers_subject_quiz_path(@subject, quiz), params: {
      grades: {
        a_mcq.id => 5,
        a_tf.id => 5,
        a_match.id => 10,
        a_written.id => 8
      }
    }

    assert_redirected_to grade_subject_quiz_path(@subject, quiz)
    assert_equal 5, a_mcq.reload.score
    assert_equal 5, a_tf.reload.score
    assert_equal 10, a_match.reload.score
    assert_equal 8, a_written.reload.score
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
end
