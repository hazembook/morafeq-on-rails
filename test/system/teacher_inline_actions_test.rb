require "application_system_test_case"

class TeacherInlineActionsTest < ApplicationSystemTestCase
  setup do
    @teacher = create(:user, :teacher)
    @subject = create(:subject, teacher: @teacher, name: "Calculus I", code: "MATH101")

    # Sign in
    visit new_session_path
    fill_in "email_address", with: @teacher.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"
  end

  test "teacher can view their subject and upload material via materials index" do
    visit subjects_path
    assert_text "My Subjects"
    assert_text "Calculus I"
    assert_text "You teach this"

    click_link "View"
    assert_selector "h1", text: "Calculus I"

    click_link "View All"
    assert_selector "h1", text: "Calculus I"
    assert_text "Materials"

    assert_link "Upload Material"

    click_link "Upload Material"
    assert_selector "h1", text: "Upload Material"

    fill_in "Title", with: "Syllabus 2026"
    attach_file "File", Rails.root.join("test/fixtures/files/test.pdf")
    click_button "Upload"

    assert_text "Material uploaded."
    assert_text "Syllabus 2026"

    assert_selector "svg.text-red-500"
    assert_text "215 Bytes"

    assert_selector "button", text: "Preview"
    preview_btn = find("button", text: "Preview")
    assert_equal "click->lightbox-gallery#open", preview_btn["data-action"]
    assert_equal "pdf", preview_btn["data-type"]
    assert_equal "Syllabus 2026", preview_btn["data-title"]
    assert_link "Download"

    click_button "Delete"
    assert_text "Material removed."
    assert_no_text "Syllabus 2026"
  end

  test "another teacher cannot see subject they do not teach" do
    other_teacher = create(:user, :teacher)

    click_button "Sign out", match: :first

    visit new_session_path
    fill_in "email_address", with: other_teacher.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit subjects_path
    assert_no_text "Calculus I"
  end
end
