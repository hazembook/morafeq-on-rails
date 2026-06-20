require "application_system_test_case"

class AdminFlowsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin)
    @teacher = create(:user, :teacher, full_name: "Dr. System Teacher")
    # Sign in
    visit new_session_path
    fill_in "email_address", with: @admin.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"
  end

  test "admin can perform CRUD on Colleges" do
    visit admin_colleges_path
    assert_selector "h1", text: "Colleges"

    # Create
    click_link "New College"
    fill_in "Name", with: "Faculty of Computer Science"
    click_button "Create College"
    assert_text "College created."
    assert_text "Faculty of Computer Science"

    # Read/Show
    college = College.last
    click_link "Show", href: admin_college_path(college)
    assert_selector "h1", text: "Faculty of Computer Science"

    # Update
    visit admin_colleges_path
    click_link "Edit", href: edit_admin_college_path(college)
    fill_in "Name", with: "Faculty of Software Engineering"
    click_button "Update College"
    assert_text "College updated."
    assert_text "Faculty of Software Engineering"

    # Delete
    within("tr", text: "Faculty of Software Engineering") do
      click_button "Delete"
    end
    assert_text "College deleted."
    assert_no_text "Faculty of Software Engineering"
  end

  test "admin can perform CRUD on Departments" do
    college = create(:college, name: "Engineering")
    visit admin_departments_path

    # Create
    click_link "New Department"
    fill_in "Name", with: "Aerospace"
    select "Engineering", from: "College"
    click_button "Create Department"
    assert_text "Department created."
    assert_text "Aerospace"

    # Update
    department = Department.last
    visit admin_departments_path
    click_link "Edit", href: edit_admin_department_path(department)
    fill_in "Name", with: "Bio-Engineering"
    click_button "Update Department"
    assert_text "Department updated."
    assert_text "Bio-Engineering"

    # Delete
    within("tr", text: "Bio-Engineering") do
      click_button "Delete"
    end
    assert_text "Department deleted."
    assert_no_text "Bio-Engineering"
  end

  test "admin can perform CRUD on Subjects" do
    college = create(:college, name: "Engineering")
    department = create(:department, name: "Electrical", college: college)
    visit admin_subjects_path

    # Create
    click_link "New Subject"
    fill_in "Code", with: "EE301"
    fill_in "Name", with: "Signals and Systems"
    select "Electrical (Engineering)", from: "Department"
    select "Dr. System Teacher", from: "Teacher"
    click_button "Create Subject"
    assert_text "Subject created."
    assert_text "EE301"

    # Update
    subject = Subject.last
    visit admin_subjects_path
    click_link "Edit", href: edit_admin_subject_path(subject)
    fill_in "Name", with: "Advanced Signals and Systems"
    click_button "Update Subject"
    assert_text "Subject updated."
    assert_text "Advanced Signals and Systems"

    # Delete
    within("tr", text: "Advanced Signals and Systems") do
      click_button "Delete"
    end
    assert_text "Subject deleted."
    assert_no_text "Advanced Signals and Systems"
  end
end
