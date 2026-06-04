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

  loadTemplate(event) {
    const templateName = event.target.value
    if (!templateName) return

    // Confirm if there are existing questions
    const wrappers = this.containerTarget.querySelectorAll('[data-nested-form-wrapper]:not([data-removed="true"])')
    if (wrappers.length > 0 && !confirm("Loading a template will replace all current questions. Do you want to proceed?")) {
      event.target.value = ""
      return
    }

    // Clear existing questions
    wrappers.forEach(w => w.remove())

    let questions = []
    if (templateName === 'quick_check') {
      questions = [
        { type: 'mcq', points: 5, question: 'Sample MCQ: What is the main capital of France?', choices: ['Paris', 'Lyon', 'Marseille'] },
        { type: 'true_false', points: 5, question: 'Sample True/False: Ruby on Rails is built with Ruby.' }
      ]
    } else if (templateName === 'mcq_quiz') {
      questions = [
        { type: 'mcq', points: 5, question: 'Question 1: Which language is Rails written in?', choices: ['Python', 'Ruby', 'JavaScript', 'Go'] },
        { type: 'mcq', points: 5, question: 'Question 2: What command runs Rails migrations?', choices: ['rails server', 'rails db:migrate', 'rails test', 'rails new'] },
        { type: 'mcq', points: 5, question: 'Question 3: What does ORM stand for?', choices: ['Object-Relational Mapping', 'Optimal Route Manager', 'Ordinary Resource Model'] }
      ]
    } else if (templateName === 'mixed_quiz') {
      questions = [
        { type: 'mcq', points: 5, question: 'Question 1: Which of the following is a lightweight file-based database?', choices: ['PostgreSQL', 'MySQL', 'SQLite', 'Oracle'] },
        { type: 'true_false', points: 5, question: 'Question 2: SQLite database files are saved as single files.' },
        { type: 'mcq', points: 5, question: 'Question 3: What command starts the rails dev server?', choices: ['rails new', 'rails db:seed', 'rails server', 'rails console'] },
        { type: 'true_false', points: 5, question: 'Question 4: True or False: ActiveStorage is a built-in Rails framework.' }
      ]
    }

    questions.forEach((q, index) => {
      const uniqueId = new Date().getTime() + index
      const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, uniqueId)
      this.containerTarget.insertAdjacentHTML('beforeend', content)

      const wrapper = this.containerTarget.lastElementChild
      
      const typeSelect = wrapper.querySelector('select[name*="[question_type]"]')
      if (typeSelect) {
        typeSelect.value = q.type
        typeSelect.dispatchEvent(new Event('change'))
      }

      const pointsInput = wrapper.querySelector('input[name*="[points]"]')
      if (pointsInput) pointsInput.value = q.points

      const questionText = wrapper.querySelector('textarea[name*="[question]"]')
      if (questionText) questionText.value = q.question

      // If it is MCQ, populate choices
      if (q.type === 'mcq' && q.choices) {
        const optionsList = wrapper.querySelector('.options-list')
        const optionTemplate = wrapper.querySelector('[data-question-editor-target="optionTemplate"]')
        if (optionsList && optionTemplate) {
          optionsList.innerHTML = "" // Clear any default options added during change event initialization
          
          q.choices.forEach(choiceText => {
            const optionHtml = optionTemplate.innerHTML
            optionsList.insertAdjacentHTML('beforeend', optionHtml)
            const addedInput = optionsList.lastElementChild.querySelector('input')
            if (addedInput) {
              addedInput.value = choiceText
            }
          })
        }
      }
    })

    this.updateLabels()
    event.target.value = "" // Reset select value so teacher can re-trigger if needed
  }
}
