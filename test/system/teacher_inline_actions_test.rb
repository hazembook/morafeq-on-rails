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

  test "teacher can view their subject and upload/manage material" do
    visit subjects_path
    assert_text "My Subjects"
    assert_text "Calculus I"
    assert_text "You teach this"

    click_link "View"
    assert_selector "h1", text: "Calculus I"

    # Check that upload buttons are present
    assert_link "Upload Material"
    assert_link "Manage Files"

    # Click upload and fill form
    click_link "Upload Material"
    assert_selector "h1", text: "Upload Material"

    fill_in "Title", with: "Syllabus 2026"
    attach_file "File", Rails.root.join("test/fixtures/files/test.pdf")
    click_button "Upload"

    assert_text "Material uploaded."
    assert_text "Syllabus 2026"

    # Verify dynamic PDF icon and size metadata are rendered
    assert_selector "svg.text-red-500"
    assert_text "58 Bytes"

    # Verify Preview button and download controls
    assert_selector "button", text: "Preview"
    preview_btn = find("button", text: "Preview")
    assert_match /openLightboxGallery\(this\)/, preview_btn[:onclick]
    assert_equal "pdf", preview_btn["data-type"]
    assert_equal "Syllabus 2026", preview_btn["data-title"]
    assert_link "Download"

    # We are redirected to Materials Index page where Delete button is present
    click_button "Delete"
    assert_text "Material removed."
    assert_no_text "Syllabus 2026"
  end

  test "another teacher cannot see upload or manage buttons" do
    other_teacher = create(:user, :teacher)

    # Sign out
    click_button "Sign out", match: :first

    # Sign in as other teacher
    visit new_session_path
    fill_in "email_address", with: other_teacher.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit subject_path(@subject)
    assert_selector "h1", text: "Calculus I"

    # Verify upload buttons are not visible for another teacher
    assert_no_link "Upload Material"
    assert_no_link "Manage Files"
  end
end
