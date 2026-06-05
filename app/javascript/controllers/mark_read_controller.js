import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  markRead(event) {
    event.preventDefault()
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": csrfToken, Accept: "application/json" },
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.success) {
          const container = this.element.closest("[id^=read_status_]")
          if (container) container.outerHTML = data.html
        }
      })
  }
}
