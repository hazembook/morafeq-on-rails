require "application_system_test_case"

class FeedScopingTest < ApplicationSystemTestCase
  setup do
    @college = create(:college, name: "Engineering College")
    @department = create(:department, name: "CS Department", college: @college)
    @teacher = create(:user, :teacher, full_name: "Dr. Ahmed")
    @subject = create(:subject, name: "Intro to programming", code: "CS101", department: @department, teacher: @teacher)

    @other_college = create(:college, name: "Arts College")
    @other_dept = create(:department, name: "Literature Dept", college: @other_college)
    @other_subject = create(:subject, name: "Introduction to Poetry", code: "EN101", department: @other_dept)

    @student = create(:user, :student)
    create(:enrollment, user: @student, subject: @subject)
  end

  test "student sees feed posts matching their academic scope and no others" do
    # Post in enrolled subject
    post_subject = Post.create!(author: @teacher, content: "Syllabus for CS101", scope: @subject)
    # Post in department of enrolled subject
    post_dept = Post.create!(author: @teacher, content: "Office hours for CS department", scope: @department, scope_type: "Department", scope_id: @department.id)
    # Post in college of enrolled subject
    post_college = Post.create!(author: @teacher, content: "Dean's welcome engineering students", scope: @college, scope_type: "College", scope_id: @college.id)
    # Post in unenrolled subject
    post_other = Post.create!(author: @teacher, content: "Poetry reading next Tuesday", scope: @other_subject)

    # Sign in as student
    visit new_session_path
    fill_in "email_address", with: @student.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit feed_index_path
    assert_text "Syllabus for CS101"
    assert_text "Office hours for CS department"
    assert_text "Dean's welcome engineering students"

    # Verify scope badges are present
    assert_text "Subject"
    assert_text "Department"
    assert_text "College"

    # Verify other subject post is not shown
    assert_no_text "Poetry reading next Tuesday"
  end

  test "teacher can create a post with file attachments" do
    # Sign in as teacher
    visit new_session_path
    fill_in "email_address", with: @teacher.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit feed_index_path
    assert_selector "h2", text: "Create Post"

    # Compose post
    fill_in "post[content]", with: "Welcome to class! Please read this attached handbook."
    select "#{@subject.code} - #{@subject.name} (Subject - #{@department.name})", from: "post[scope]"
    attach_file "post[attachments][]", Rails.root.join("test/fixtures/files/test.pdf")
    click_button "Post"

    assert_text "Post created."
    assert_text "Welcome to class! Please read this attached handbook."
    assert_text "test.pdf"

    # Verify preview and download controls exist for the PDF
    assert_selector "button", text: "Preview"
    preview_btn = find("button", text: "Preview")
    assert_match /openLightboxGallery\(this\)/, preview_btn[:onclick]
    assert_equal "pdf", preview_btn["data-type"]
    assert_equal "test.pdf", preview_btn["data-title"]

    # Verify download icon link exists
    assert_selector "a[title='Download']"

    # Verify lightbox iframe placeholder is present but hidden
    assert_selector "#lightbox-pdf", visible: false
  end

  test "admin can create a General post and all users see it" do
    admin = create(:user, :admin)
    visit new_session_path
    fill_in "email_address", with: admin.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit feed_index_path
    assert_selector "h2", text: "Create Post"

    # Compose post scoped to General
    fill_in "post[content]", with: "System maintenance this Saturday at midnight."
    select "General (University-wide)", from: "post[scope]"
    click_button "Post"

    assert_text "Post created."
    assert_text "System maintenance this Saturday at midnight."
    assert_text "General"

    # Sign out
    click_button "Sign out", match: :first

    # Sign in as a student who is not enrolled in any subjects
    student2 = create(:user, :student)
    visit new_session_path
    fill_in "email_address", with: student2.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit feed_index_path
    assert_text "System maintenance this Saturday at midnight."
    assert_text "General"
  end

  test "teacher can create a post with image attachment that has lightbox markup" do
    # Sign in as teacher
    visit new_session_path
    fill_in "email_address", with: @teacher.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit feed_index_path
    assert_selector "h2", text: "Create Post"

    # Compose post
    fill_in "post[content]", with: "Look at this nice picture!"
    select "#{@subject.code} - #{@subject.name} (Subject - #{@department.name})", from: "post[scope]"
    attach_file "post[attachments][]", Rails.root.join("test/fixtures/files/test.gif")
    click_button "Post"

    assert_text "Post created."
    assert_text "Look at this nice picture!"

    # We should have an image element rendered within the lightbox zoom-in container
    assert_selector "div.cursor-zoom-in img"

    # Verify that clicking it triggers showLightbox with the image source
    zoom_container = find("div.cursor-zoom-in")
    assert_match /openLightboxGallery\(this\)/, zoom_container[:onclick]
    assert_equal "image", zoom_container["data-type"]
    assert_equal "test.gif", zoom_container["data-title"]

    # Lightbox modal should be present but hidden by default
    assert_selector "#lightbox-modal", visible: false

    # The image placeholder inside lightbox should be present but hidden
    assert_selector "#lightbox-img", visible: false
  end

  test "teacher can edit and delete their own post" do
    post = Post.create!(author: @teacher, content: "Original content", scope: @subject)
    post.attachments.attach(io: File.open(Rails.root.join("test/fixtures/files/test.pdf")), filename: "test.pdf", content_type: "application/pdf")

    # Sign in
    visit new_session_path
    fill_in "email_address", with: @teacher.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"

    visit feed_index_path
    assert_text "Original content"
    assert_text "test.pdf"

    click_link "Edit"
    
    assert_text "test.pdf"
    check "remove_attachments[]"

    fill_in "post[content]", with: "Updated content by teacher"
    click_button "Save"

    assert_text "Post updated."
    assert_text "Updated content by teacher"
    assert_no_text "Original content"
    assert_no_text "test.pdf"

    click_button "Delete"

    assert_text "Post deleted."
    assert_no_text "Updated content by teacher"
  end
end
