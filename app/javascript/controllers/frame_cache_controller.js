import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("turbo:frame-load", () => {
      this.element.removeAttribute("src")
    })

    this.boundBeforeCache = this.removeSrc.bind(this)
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  removeSrc() {
    this.element.removeAttribute("src")
  }
}
