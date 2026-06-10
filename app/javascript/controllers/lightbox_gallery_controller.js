import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modal", "img", "pdf", "video", "audioContainer", "audio",
    "toolbarTitle", "toolbarIcon", "toolbarAction", "toolbarDownload",
    "toolbarCounter", "prevBtn", "nextBtn", "audioTitle"
  ]

  items = []
  index = -1

  connect() {
    this.boundKeydown = this.#keydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
  }

  open(event) {
    const element = event.currentTarget
    const container = element.closest("[data-lightbox-gallery]")

    if (!container) {
      this.items = [{
        src: element.dataset.src,
        type: element.dataset.type,
        title: element.dataset.title,
        download: element.dataset.download || element.dataset.src
      }]
      this.index = 0
    } else {
      const triggers = Array.from(container.querySelectorAll(".lightbox-trigger"))
      this.items = triggers.map(t => ({
        src: t.dataset.src,
        type: t.dataset.type,
        title: t.dataset.title,
        download: t.dataset.download || t.dataset.src
      }))
      this.index = triggers.indexOf(element)
    }

    this.#updateView()
  }

  closeBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.#doClose()
    }
  }

  close(event) {
    event.stopPropagation()
    this.#doClose()
  }

  navigate(event) {
    event.stopPropagation()
    const dir = parseInt(event.params.direction || 1, 10)
    if (this.items.length <= 1) return
    this.index = (this.index + dir + this.items.length) % this.items.length
    this.#updateView()
  }

  stop(event) {
    event.stopPropagation()
  }

  #doClose() {
    const activeEl = [this.imgTarget, this.pdfTarget, this.videoTarget, this.audioContainerTarget]
      .find(el => el && el.style.display !== "none")

    if (activeEl) {
      activeEl.classList.remove("scale-100", "opacity-100")
      activeEl.classList.add("scale-95", "opacity-0")
    }

    if (this.videoTarget) this.videoTarget.pause()
    if (this.audioTarget) this.audioTarget.pause()

    setTimeout(() => {
      this.modalTarget.style.display = "none"
      ;[this.imgTarget, this.pdfTarget, this.videoTarget].forEach(el => { if (el) el.src = "" })
      if (this.audioTarget) this.audioTarget.src = ""
      this.items = []
      this.index = -1
    }, 300)
  }

  #updateView() {
    if (!this.modalTarget || this.index < 0 || this.index >= this.items.length) return

    const item = this.items[this.index]

    if (this.toolbarTitleTarget) this.toolbarTitleTarget.textContent = item.title || "Document Viewer"
    if (this.toolbarActionTarget) this.toolbarActionTarget.href = item.src
    if (this.toolbarDownloadTarget) this.toolbarDownloadTarget.href = item.download

    if (this.toolbarCounterTarget) {
      if (this.items.length > 1) {
        this.toolbarCounterTarget.textContent = `${this.index + 1} of ${this.items.length}`
        this.toolbarCounterTarget.style.display = "inline-block"
      } else {
        this.toolbarCounterTarget.style.display = "none"
      }
    }

    if (this.prevBtnTarget && this.nextBtnTarget) {
      const show = this.items.length > 1 ? "flex" : "none"
      this.prevBtnTarget.style.display = show
      this.nextBtnTarget.style.display = show
    }

    if (this.toolbarIconTarget) {
      let svg = ""
      if (item.type === "image") {
        svg = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>'
      } else if (item.type === "pdf") {
        svg = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 9h1.5M9 13h6m-6 4h6"></path>'
      } else if (item.type === "video") {
        svg = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>'
      } else if (item.type === "audio") {
        svg = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"></path>'
      }
      this.toolbarIconTarget.innerHTML = svg
    }

    const activeVideo = this.videoTarget && this.videoTarget.style.display !== "none"
    const activeAudio = this.audioContainerTarget && this.audioContainerTarget.style.display !== "none"
    if (activeVideo) this.videoTarget.pause()
    if (activeAudio) this.audioTarget.pause()

    const resetEl = (el) => {
      if (!el) return
      el.style.display = "none"
      el.src = ""
      el.classList.add("scale-95", "opacity-0")
      el.classList.remove("scale-100", "opacity-100")
    }

    resetEl(this.imgTarget)
    resetEl(this.pdfTarget)
    resetEl(this.videoTarget)
    if (this.audioContainerTarget && this.audioTarget) {
      this.audioContainerTarget.style.display = "none"
      this.audioTarget.src = ""
      this.audioContainerTarget.classList.add("scale-95", "opacity-0")
      this.audioContainerTarget.classList.remove("scale-100", "opacity-100")
    }

    let targetEl = null

    if (item.type === "image") {
      this.imgTarget.src = item.src
      this.imgTarget.style.display = "block"
      targetEl = this.imgTarget
    } else if (item.type === "pdf") {
      this.pdfTarget.src = item.src
      this.pdfTarget.style.display = "block"
      targetEl = this.pdfTarget
    } else if (item.type === "video") {
      this.videoTarget.src = item.src
      this.videoTarget.style.display = "block"
      targetEl = this.videoTarget
    } else if (item.type === "audio") {
      this.audioTarget.src = item.src
      this.audioContainerTarget.style.display = "flex"
      if (this.audioTitleTarget) this.audioTitleTarget.textContent = item.title || "Audio Player"
      targetEl = this.audioContainerTarget
    }

    if (!targetEl) return

    this.modalTarget.style.display = "flex"
    setTimeout(() => {
      targetEl.classList.remove("scale-95", "opacity-0")
      targetEl.classList.add("scale-100", "opacity-100")
    }, 10)
  }

  #keydown(event) {
    const modal = this.modalTarget
    if (!modal || modal.style.display === "none") return

    if (event.key === "Escape") {
      this.#doClose()
    } else if (event.key === "ArrowRight") {
      const dir = document.dir === "rtl" ? -1 : 1
      if (this.items.length <= 1) return
      this.index = (this.index + dir + this.items.length) % this.items.length
      this.#updateView()
    } else if (event.key === "ArrowLeft") {
      const dir = document.dir === "rtl" ? 1 : -1
      if (this.items.length <= 1) return
      this.index = (this.index + dir + this.items.length) % this.items.length
      this.#updateView()
    }
  }
}
