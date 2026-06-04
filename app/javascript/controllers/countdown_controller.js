import { Controller } from "@hotwire/stimulus"

export default class extends Controller {
  static values = {
    dueAt: String
  }
  static targets = ["timer"]

  connect() {
    this.endTime = new Date(this.dueAtValue).getTime()
    this.update()
    this.interval = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  update() {
    const now = new Date().getTime()
    const distance = this.endTime - now

    if (distance <= 0) {
      clearInterval(this.interval)
      if (this.hasTimerTarget) {
        this.timerTarget.textContent = "00:00:00"
      }
      // Reload page to apply the closed state from backend
      window.location.reload()
      return
    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24))
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((distance % (1000 * 60)) / 1000)

    let formatted = ""
    if (days > 0) {
      formatted += `${days}d `
    }
    formatted += [
      hours.toString().padStart(2, '0'),
      minutes.toString().padStart(2, '0'),
      seconds.toString().padStart(2, '0')
    ].join(':')

    if (this.hasTimerTarget) {
      this.timerTarget.textContent = formatted
    }
  }
}
