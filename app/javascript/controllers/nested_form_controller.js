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
        { type: 'mcq', points: 5, question: 'Sample MCQ: What is the main capital of France?', choices: 'Paris\nLyon\nMarseille' },
        { type: 'true_false', points: 5, question: 'Sample True/False: Ruby on Rails is built with Ruby.', choices: '' }
      ]
    } else if (templateName === 'mcq_quiz') {
      questions = [
        { type: 'mcq', points: 5, question: 'Question 1: Which language is Rails written in?', choices: 'Python\nRuby\nJavaScript\nGo' },
        { type: 'mcq', points: 5, question: 'Question 2: What command runs Rails migrations?', choices: 'rails server\nrails db:migrate\nrails test\nrails new' },
        { type: 'mcq', points: 5, question: 'Question 3: What does ORM stand for?', choices: 'Object-Relational Mapping\nOptimal Route Manager\nOrdinary Resource Model' }
      ]
    } else if (templateName === 'comprehensive') {
      questions = [
        { type: 'mcq', points: 5, question: 'Sample MCQ: Which of the following is a database?', choices: 'HTML\nCSS\nSQLite\nHTTP' },
        { type: 'true_false', points: 5, question: 'Sample True/False: SQLite database files are saved as single files.', choices: '' },
        { type: 'match', points: 10, question: 'Sample Matching: Match the countries to their capitals.', choices: 'France: Paris\nSpain: Madrid\nItaly: Rome' },
        { type: 'written', points: 10, question: 'Sample Written: Explain the MVC architecture pattern.', choices: '' }
      ]
    }

    questions.forEach((q, index) => {
      const uniqueId = new Date().getTime() + index
      const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, uniqueId)
      this.containerTarget.insertAdjacentHTML('beforeend', content)

      const wrapper = this.containerTarget.lastElementChild
      
      const typeSelect = wrapper.querySelector('select[name*="[question_type]"]')
      if (typeSelect) typeSelect.value = q.type

      const pointsInput = wrapper.querySelector('input[name*="[points]"]')
      if (pointsInput) pointsInput.value = q.points

      const questionText = wrapper.querySelector('textarea[name*="[question]"]')
      if (questionText) questionText.value = q.question

      const choicesText = wrapper.querySelector('textarea[name*="[choices_text]"]')
      if (choicesText) choicesText.value = q.choices
    })

    this.updateLabels()
    event.target.value = "" // Reset select value so teacher can re-trigger if needed
  }
}
