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
      
      // Show add option button
      const addBtn = this.mcqOptionsContainerTarget.querySelector('[data-action*="addOption"]')
      if (addBtn) addBtn.classList.remove("hidden")
      
      // Enable editing and removing
      this.mcqOptionsContainerTarget.querySelectorAll('input').forEach(i => {
        i.readOnly = false
        i.placeholder = "Enter option text..."
      })
      this.mcqOptionsContainerTarget.querySelectorAll('button[data-action*="removeOption"]').forEach(b => b.classList.remove("hidden"))
      
      // Ensure we have at least 2 options if none exist
      const existingOptions = this.mcqOptionsContainerTarget.querySelectorAll('[data-option-wrapper="true"]')
      if (existingOptions.length === 0) {
        this.addOption()
        this.addOption()
      }
    } else if (type === "true_false") {
      this.mcqOptionsContainerTarget.classList.remove("hidden")
      
      // Hide add option button
      const addBtn = this.mcqOptionsContainerTarget.querySelector('[data-action*="addOption"]')
      if (addBtn) addBtn.classList.add("hidden")
      
      // Set to read-only True and False
      const optionsList = this.mcqOptionsContainerTarget.querySelector('.options-list')
      optionsList.innerHTML = ""
      
      const optionTemplate = this.optionTemplateTarget.innerHTML
      
      // Add True option
      optionsList.insertAdjacentHTML('beforeend', optionTemplate)
      const inputTrue = optionsList.lastElementChild.querySelector('input')
      inputTrue.value = "True"
      inputTrue.readOnly = true
      optionsList.lastElementChild.querySelector('button[data-action*="removeOption"]').classList.add("hidden")

      // Add False option
      optionsList.insertAdjacentHTML('beforeend', optionTemplate)
      const inputFalse = optionsList.lastElementChild.querySelector('input')
      inputFalse.value = "False"
      inputFalse.readOnly = true
      optionsList.lastElementChild.querySelector('button[data-action*="removeOption"]').classList.add("hidden")
    }
  }

  addOption(event) {
    if (event) event.preventDefault()

    const templateContent = this.optionTemplateTarget.innerHTML
    this.mcqOptionsContainerTarget.querySelector('.options-list').insertAdjacentHTML('beforeend', templateContent)
  }

  removeOption(event) {
    event.preventDefault()
    
    // Ensure we do not remove below 2 options for MCQ
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
