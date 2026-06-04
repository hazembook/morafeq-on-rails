import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkVisibility()
    this.observer = new MutationObserver(() => this.checkVisibility())
    this.observer.observe(this.element, { childList: true, attributes: true })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  checkVisibility() {
    const currentUserIdMeta = document.head.querySelector("meta[name='current-user-id']")
    const currentUserId = currentUserIdMeta ? parseInt(currentUserIdMeta.content) : null
    const typerId = parseInt(this.element.getAttribute("data-typer-id"))

    if (typerId && currentUserId && typerId === currentUserId) {
      this.element.style.display = "none"
    } else {
      this.element.style.display = ""
    }
  }
}
