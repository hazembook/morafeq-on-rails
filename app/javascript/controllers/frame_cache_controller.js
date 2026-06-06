import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("turbo:frame-load", () => {
      this.element.removeAttribute("src")
    })
  }
}
