import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "container", "template" ]

  connect() {
    this.updateLabels()
  }

  add(event) {
    event.preventDefault()
    
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
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
    const questions = this.containerTarget.querySelectorAll('[data-nested-form-wrapper]:not([data-removed="true"])')
    questions.forEach((question, index) => {
      const label = question.querySelector('[data-question-label]')
      if (label) {
        label.textContent = `Question ${index + 1}`
      }
    })
  }


}
