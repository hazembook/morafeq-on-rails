import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  markRead(event) {
    event.preventDefault()
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => {
        Turbo.renderStreamMessage(html)
      })
  }
}
