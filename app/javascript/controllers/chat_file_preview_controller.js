import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.selectedFiles = []
  }

  preview(event) {
    this.selectedFiles = Array.from(event.target.files)
    this.render()
  }

  remove(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    this.selectedFiles.splice(index, 1)

    const dt = new DataTransfer()
    this.selectedFiles.forEach(f => dt.items.add(f))
    this.inputTarget.files = dt.files

    this.render()
  }

  render() {
    this.previewTarget.innerHTML = ""

    if (this.selectedFiles.length === 0) {
      this.previewTarget.classList.add("hidden")
      return
    }

    this.previewTarget.classList.remove("hidden")

    this.selectedFiles.forEach((file, i) => {
      const chip = document.createElement("div")
      chip.className = "flex items-center gap-1.5 px-2 py-1 bg-gray-100 rounded-lg border border-gray-200 text-xs text-gray-700 max-w-[160px] group relative"

      if (file.type.startsWith("image/")) {
        const img = document.createElement("img")
        img.className = "w-6 h-6 object-cover rounded shrink-0"
        img.src = URL.createObjectURL(file)
        chip.appendChild(img)
      } else {
        const icon = document.createElement("span")
        icon.className = "shrink-0 text-gray-400"
        icon.textContent = "\u{1F4CE}"
        chip.appendChild(icon)
      }

      const name = document.createElement("span")
      name.className = "truncate"
      name.textContent = file.name
      chip.appendChild(name)

      const remove = document.createElement("button")
      remove.type = "button"
      remove.dataset.index = i
      remove.dataset.action = "click->chat-file-preview#remove"
      remove.className = "shrink-0 text-gray-400 hover:text-red-500 transition-colors cursor-pointer p-0.5 -me-1 bg-transparent border-0"
      remove.innerHTML = `<svg class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>`
      chip.appendChild(remove)

      this.previewTarget.appendChild(chip)
    })
  }
}
