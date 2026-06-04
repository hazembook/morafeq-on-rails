import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    authorId: Number
  }

  connect() {
    const currentUserIdMeta = document.querySelector('meta[name="current-user-id"]')
    const currentUserRoleMeta = document.querySelector('meta[name="current-user-role"]')

    if (!currentUserIdMeta) return

    const currentUserId = parseInt(currentUserIdMeta.content, 10)
    const currentUserRole = currentUserRoleMeta ? currentUserRoleMeta.content : ""

    const isAuthor = currentUserId === this.authorIdValue
    const isAdmin = currentUserRole === "admin"

    const messageAuthorEl = this.element.querySelector(".post-action-message-author")
    const editDeleteEl = this.element.querySelector(".post-action-edit-delete")

    if (messageAuthorEl) {
      if (!isAuthor) {
        messageAuthorEl.classList.remove("hidden")
        messageAuthorEl.style.display = "inline-block"
      } else {
        messageAuthorEl.classList.add("hidden")
        messageAuthorEl.style.display = "none"
      }
    }

    if (editDeleteEl) {
      if (isAuthor || isAdmin) {
        editDeleteEl.classList.remove("hidden")
        editDeleteEl.style.display = "inline-block"
      } else {
        editDeleteEl.classList.add("hidden")
        editDeleteEl.style.display = "none"
      }
    }
  }
}
