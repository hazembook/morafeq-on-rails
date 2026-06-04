import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["score", "up", "down"]
  static values = {
    postId: Number,
    baseScore: Number
  }

  connect() {
    this.voteState = localStorage.getItem(`post_vote_${this.postIdValue}`) || "none"
    this.updateUI()
  }

  upvote() {
    if (this.voteState === "up") {
      this.voteState = "none"
    } else {
      this.voteState = "up"
    }
    localStorage.setItem(`post_vote_${this.postIdValue}`, this.voteState)
    this.updateUI()
  }

  downvote() {
    if (this.voteState === "down") {
      this.voteState = "none"
    } else {
      this.voteState = "down"
    }
    localStorage.setItem(`post_vote_${this.postIdValue}`, this.voteState)
    this.updateUI()
  }

  updateUI() {
    let scoreOffset = 0
    if (this.voteState === "up") {
      scoreOffset = 1
    } else if (this.voteState === "down") {
      scoreOffset = -1
    }

    const scoreVal = this.baseScoreValue + scoreOffset

    this.upTargets.forEach(el => {
      if (this.voteState === "up") {
        el.classList.add("text-orange-500")
        el.classList.remove("text-gray-400")
      } else {
        el.classList.add("text-gray-400")
        el.classList.remove("text-orange-500")
      }
    })

    this.downTargets.forEach(el => {
      if (this.voteState === "down") {
        el.classList.add("text-blue-500")
        el.classList.remove("text-gray-400")
      } else {
        el.classList.add("text-gray-400")
        el.classList.remove("text-blue-500")
      }
    })

    this.scoreTargets.forEach(el => {
      el.innerText = scoreVal
      if (this.voteState === "up") {
        el.className = "text-xs font-bold text-orange-500 px-1 text-center"
      } else if (this.voteState === "down") {
        el.className = "text-xs font-bold text-blue-500 px-1 text-center"
      } else {
        el.className = "text-xs font-bold text-gray-700 px-1 text-center"
      }
    })
  }
}
