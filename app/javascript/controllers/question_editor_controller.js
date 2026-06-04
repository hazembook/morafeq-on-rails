import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "typeSelect", "mcqOptionsContainer", "optionTemplate" ]
  static values = { index: String }

  connect() {
    this.changeType()
  }

  changeType() {
    const type = this.typeSelectTarget.value
    if (type === "mcq") {
      this.mcqOptionsContainerTarget.classList.remove("hidden")
      
      // Ensure we have at least 2 options if none exist
      const existingOptions = this.mcqOptionsContainerTarget.querySelectorAll('[data-option-wrapper="true"]')
      if (existingOptions.length === 0) {
        this.addOption()
        this.addOption()
      }
    } else {
      this.mcqOptionsContainerTarget.classList.add("hidden")
    }
  }

  addOption(event) {
    if (event) event.preventDefault()

    const templateContent = this.optionTemplateTarget.innerHTML
    this.mcqOptionsContainerTarget.querySelector('.options-list').insertAdjacentHTML('beforeend', templateContent)
  }

  removeOption(event) {
    event.preventDefault()
    
    // Ensure we do not remove below 2 options
    const existingOptions = this.mcqOptionsContainerTarget.querySelectorAll('[data-option-wrapper="true"]')
    if (existingOptions.length <= 2) {
      alert("An MCQ question must have at least 2 options.")
      return
    }

    const wrapper = event.target.closest('[data-option-wrapper="true"]')
    if (wrapper) {
      wrapper.remove()
    }
  }
}
