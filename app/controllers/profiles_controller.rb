class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user

    if @user.student?
      # Calculate student stats
      subjects = @user.subjects

      # Quiz stats
      quiz_answers = @user.quiz_answers
      graded_quiz_answers = quiz_answers.where.not(score: nil)
      total_quiz_earned = graded_quiz_answers.sum(:score)
      total_quiz_possible = graded_quiz_answers.joins(:quiz_question).sum("quiz_questions.points")
      @quiz_average = total_quiz_possible > 0 ? (total_quiz_earned.to_f / total_quiz_possible * 100).round(1) : nil
      @quizzes_completed = Quiz.where(id: @user.quiz_answers.joins(:quiz_question).select("quiz_questions.quiz_id")).distinct.count
      @total_quizzes = Quiz.where(subject_id: subjects.select(:id)).count

      # Assignment stats
      submissions = @user.assignment_submissions
      graded_submissions = submissions.where.not(score: nil)
      total_assignment_earned = graded_submissions.sum(:score)
      total_assignment_possible = graded_submissions.joins(:assignment).sum("assignments.total_points")
      @assignment_average = total_assignment_possible > 0 ? (total_assignment_earned.to_f / total_assignment_possible * 100).round(1) : nil
      @assignments_completed = submissions.count
      @total_assignments = Assignment.where(subject_id: subjects.select(:id)).count

      # Attendance stats
      attendances = @user.attendances
      @total_attendances = attendances.count
      @present_attendances = attendances.where(status: "present").count
      @excused_attendances = attendances.where(status: "excused").count
      @absent_attendances = attendances.where(status: "absent").count
      @attendance_rate = @total_attendances > 0 ? (((@present_attendances + @excused_attendances).to_f / @total_attendances) * 100).round(1) : nil

      # Subject-wise analysis breakdown
      @subject_stats = subjects.map do |subject|
        sub_attendances = @user.attendances.where(subject_id: subject.id)
        sub_total_att = sub_attendances.count
        sub_present_att = sub_attendances.where(status: "present").count
        sub_excused_att = sub_attendances.where(status: "excused").count
        att_rate = sub_total_att > 0 ? (((sub_present_att + sub_excused_att).to_f / sub_total_att) * 100).round(1) : nil

        sub_answers = @user.quiz_answers.joins(:quiz_question).where(quiz_questions: { quiz_id: Quiz.where(subject_id: subject.id).select(:id) })
        graded_sub_answers = sub_answers.where.not(score: nil)
        quiz_earned = graded_sub_answers.sum(:score)
        quiz_possible = graded_sub_answers.joins(:quiz_question).sum("quiz_questions.points")
        quiz_avg = quiz_possible > 0 ? (quiz_earned.to_f / quiz_possible * 100).round(1) : nil

        sub_submissions = @user.assignment_submissions.joins(:assignment).where(assignments: { subject_id: subject.id })
        graded_sub_submissions = sub_submissions.where.not(score: nil)
        assignment_earned = graded_sub_submissions.sum(:score)
        assignment_possible = graded_sub_submissions.sum("assignments.total_points")
        assignment_avg = assignment_possible > 0 ? (assignment_earned.to_f / assignment_possible * 100).round(1) : nil

        {
          subject: subject,
          attendance_rate: att_rate,
          quiz_average: quiz_avg,
          assignment_average: assignment_avg,
          attendance_total: sub_total_att,
          attendance_present: sub_present_att
        }
      end

    elsif @user.teacher?
      # Calculate teacher stats
      taught_subjects = @user.taught_subjects
      @total_students = Enrollment.where(subject_id: taught_subjects.select(:id)).distinct.count(:user_id)
      @total_posts = @user.authored_posts.count

      @taught_subject_stats = taught_subjects.map do |subject|
        student_count = subject.enrollments.count

        total_att = Attendance.where(subject_id: subject.id).count
        present_att = Attendance.where(subject_id: subject.id, status: "present").count
        excused_att = Attendance.where(subject_id: subject.id, status: "excused").count
        att_rate = total_att > 0 ? (((present_att + excused_att).to_f / total_att) * 100).round(1) : nil

        answers = QuizAnswer.joins(:quiz_question).where(quiz_questions: { quiz_id: Quiz.where(subject_id: subject.id).select(:id) })
        graded_answers = answers.where.not(score: nil)
        quiz_earned = graded_answers.sum(:score)
        quiz_possible = graded_answers.joins(:quiz_question).sum("quiz_questions.points")
        quiz_avg = quiz_possible > 0 ? (quiz_earned.to_f / quiz_possible * 100).round(1) : nil

        submissions = AssignmentSubmission.joins(:assignment).where(assignments: { subject_id: subject.id })
        graded_submissions = submissions.where.not(score: nil)
        assignment_earned = graded_submissions.sum(:score)
        assignment_possible = graded_submissions.sum("assignments.total_points")
        assignment_avg = assignment_possible > 0 ? (assignment_earned.to_f / assignment_possible * 100).round(1) : nil

        {
          subject: subject,
          student_count: student_count,
          attendance_rate: att_rate,
          quiz_average: quiz_avg,
          assignment_average: assignment_avg
        }
      end

    elsif @user.admin?
      # System-wide statistics for admin
      @system_stats = {
        colleges: College.count,
        departments: Department.count,
        subjects: Subject.count,
        students: User.where(role: :student).count,
        teachers: User.where(role: :teacher).count,
        posts: Post.count,
        messages: Message.count
      }
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:full_name, :bio, :avatar)
  end
end
