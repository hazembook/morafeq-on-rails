import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { datetime: String, format: String }

  connect() {
    if (!this.hasDatetimeValue) return
    this.update()
    this.interval = setInterval(() => this.update(), 60000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  update() {
    const relative = this.relativeTime(this.datetimeValue)
    if (this.hasFormatValue) {
      this.element.textContent = this.formatValue.replace("%{time}", relative)
    } else {
      this.element.textContent = relative
    }
  }

  relativeTime(isoString) {
    const now = new Date()
    const date = new Date(isoString)
    const diffMs = now - date
    const diffSec = Math.floor(Math.abs(diffMs) / 1000)

    if (diffSec < 60) return "less than a minute"
    const diffMin = Math.floor(diffSec / 60)
    if (diffMin < 2) return "1 minute"
    if (diffMin < 45) return `${diffMin} minutes`
    if (diffMin < 90) return "about 1 hour"
    const diffHours = Math.floor(diffMin / 60)
    if (diffHours < 22) return `about ${diffHours} hours`
    if (diffHours < 36) return "1 day"
    const diffDays = Math.floor(diffHours / 24)
    if (diffDays < 26) return `${diffDays} days`
    if (diffDays < 45) return "about 1 month"
    if (diffDays < 345) return `${Math.floor(diffDays / 30)} months`
    const diffYears = Math.floor(diffDays / 365)
    return diffYears < 2 ? "about 1 year" : `${diffYears} years`
  }
}
