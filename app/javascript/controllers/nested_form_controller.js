import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "container", "template" ]

  connect() {
    this.updateLabels()
  }

  add(event) {
    event.preventDefault()
    
    const timestamp = new Date().getTime()
    this._counter = (this._counter || timestamp) + 1
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this._counter)
    this.containerTarget.insertAdjacentHTML('beforeend', content)
    this.updateLabels()
  }

  remove(event) {
    event.preventDefault()
    
    const wrapper = event.target.closest('[data-nested-form-wrapper]')
    if (!wrapper) return

    const destroyField = wrapper.querySelector('[name*="[_destroy]"]')
    if (destroyField) {
      destroyField.value = '1'
      wrapper.style.display = 'none'
      wrapper.setAttribute('data-removed', 'true')
    } else {
      wrapper.remove()
    }
    
    this.updateLabels()
  }

  updateLabels() {
    if (!this.hasContainerTarget) return
    const questions = this.containerTarget.querySelectorAll('[data-nested-form-wrapper]:not([data-removed="true"])')
    questions.forEach((question, index) => {
      const label = question.querySelector('[data-question-label]')
      if (label) {
        const template = label.getAttribute('data-template') || 'Question %{num}'
        label.textContent = template.replace('%{num}', index + 1)
      }
    })
  }


}
