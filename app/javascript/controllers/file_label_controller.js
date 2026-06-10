import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { target: String }

  update(event) {
    const label = document.getElementById(this.targetValue)
    if (!label) return

    const { files } = event.currentTarget
    const tmpl = event.currentTarget.dataset.selectedTemplate
    const ph = event.currentTarget.dataset.placeholder

    if (files.length > 0) {
      label.textContent = tmpl.replace("%{count}", files.length)
    } else {
      label.textContent = ph
    }
  }
}
