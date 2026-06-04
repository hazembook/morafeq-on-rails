import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    roomId: Number,
    url: String
  }

  connect() {
    this.isTyping = false
    this.typingTimeout = null
  }

  typing(event) {
    if (!this.isTyping) {
      this.isTyping = true
      this.sendTypingStatus(true)
    }

    clearTimeout(this.typingTimeout)
    this.typingTimeout = setTimeout(() => {
      this.isTyping = false
      this.sendTypingStatus(false)
    }, 2000)
  }

  sendTypingStatus(status) {
    const tokenMeta = document.querySelector('meta[name="csrf-token"]')
    const token = tokenMeta ? tokenMeta.getAttribute('content') : ''
    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ typing: status })
    }).catch(err => console.error("Failed to send typing status:", err))
  }
}
