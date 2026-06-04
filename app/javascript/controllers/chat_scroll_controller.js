import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.mutationObserver = new MutationObserver(() => this.scrollToBottom())
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
}
