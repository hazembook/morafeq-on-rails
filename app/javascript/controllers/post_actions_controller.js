import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  navigateToPost(event) {
    if (event.target.closest("a, button, input, label, textarea, select, iframe, .lightbox-trigger, [data-lightbox-gallery]")) return
    const url = this.element.getAttribute("data-post-url")
    if (url) {
      Turbo.visit(url)
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
