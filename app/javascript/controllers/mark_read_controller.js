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
      .then((r) => {
        console.log("mark_read status:", r.status, r.statusText)
        console.log("mark_read content-type:", r.headers.get("content-type"))
        return r.text().then(t => { console.log("mark_read body:", t); return t })
      })
      .then((t) => JSON.parse(t))
      .then((data) => {
        console.log("mark_read data.success:", data.success)
        console.log("mark_read data.html:", data.html)
        if (data.success) {
          const container = this.element.closest("[id^=read_status_]")
          console.log("mark_read container:", container)
          if (container) {
            console.log("mark_read swapping outerHTML")
            container.outerHTML = data.html
            console.log("mark_read swap done, checking DOM:", document.getElementById("read_status_" + container.id.replace("read_status_", "")))
          }
        }
      })
      .catch(e => console.error("mark_read error:", e))
  }
}
