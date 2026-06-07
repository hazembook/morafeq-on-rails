import { Controller } from "@hotwired/stimulus"

// Prevent lazy-loaded frames from flickering or re-fetching when Turbo Drive swaps or restores the body.
document.addEventListener("turbo:before-render", (event) => {
  const newBody = event.detail.newBody
  const loadedFrames = document.querySelectorAll('turbo-frame[data-controller~="frame-cache"]:not([src])')

  loadedFrames.forEach((frame) => {
    const newFrame = newBody.querySelector(`#${frame.id}`)
    if (newFrame) {
      newFrame.innerHTML = frame.innerHTML
      newFrame.removeAttribute("src")
    }
  })
})

export default class extends Controller {
  connect() {
    this.loaded = false
    this.element.addEventListener("turbo:frame-load", () => {
      this.loaded = true
      this.element.removeAttribute("src")
    })

    this.boundBeforeCache = this.maybeStripSrc.bind(this)
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  maybeStripSrc() {
    if (this.loaded) this.element.removeAttribute("src")
  }
}

