import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "room", "user", "roomsHeader", "usersHeader"]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    
    let visibleRooms = 0
    let visibleUsers = 0

    this.roomTargets.forEach(room => {
      const name = room.getAttribute("data-search-name").toLowerCase()
      if (name.includes(query)) {
        room.classList.remove("hidden")
        visibleRooms++
      } else {
        room.classList.add("hidden")
      }
    })

    this.userTargets.forEach(user => {
      const name = user.getAttribute("data-search-name").toLowerCase()
      if (name.includes(query)) {
        user.classList.remove("hidden")
        visibleUsers++
      } else {
        user.classList.add("hidden")
      }
    })

    // Show/hide section headers
    if (this.hasRoomsHeaderTarget) {
      if (visibleRooms > 0) {
        this.roomsHeaderTarget.classList.remove("hidden")
      } else {
        this.roomsHeaderTarget.classList.add("hidden")
      }
    }

    if (this.hasUsersHeaderTarget) {
      // Show user search results only when query is present
      if (visibleUsers > 0 && query.length > 0) {
        this.usersHeaderTarget.classList.remove("hidden")
      } else {
        this.usersHeaderTarget.classList.add("hidden")
      }
    }
  }
}
