import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.mutationObserver = new MutationObserver(() => this.scrollIfNearBottom())
    this.mutationObserver.observe(this.element, { childList: true })
  }

  disconnect() {
    if (this.mutationObserver) {
      this.mutationObserver.disconnect()
    }
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }

  scrollIfNearBottom() {
    const threshold = 80
    const distanceFromBottom = this.element.scrollHeight - this.element.scrollTop - this.element.clientHeight
    if (distanceFromBottom < threshold) {
      this.element.scrollTop = this.element.scrollHeight
    }
  }
}
