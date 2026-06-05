import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "room", "user", "usersHeader", "tab"]

  connect() {
    // Restore search query
    const savedQuery = sessionStorage.getItem("chat_search_query") || ""
    if (this.hasInputTarget) {
      this.inputTarget.value = savedQuery
    }

    // Restore active tab
    const savedTab = sessionStorage.getItem("chat_active_tab") || "all"
    this.activeTab = savedTab

    // Apply restored active tab styling
    this.tabTargets.forEach(tab => {
      const isCurrent = tab.getAttribute("data-tab") === savedTab
      if (isCurrent) {
        tab.classList.remove("text-gray-600", "hover:text-gray-900")
        tab.classList.add("bg-white", "text-blue-600", "shadow-sm")
      } else {
        tab.classList.remove("bg-white", "text-blue-600", "shadow-sm")
        tab.classList.add("text-gray-600", "hover:text-gray-900")
      }
    })

    this.filter()
  }

  changeTab(event) {
    const selectedTab = event.currentTarget.getAttribute("data-tab")
    this.activeTab = selectedTab
    sessionStorage.setItem("chat_active_tab", selectedTab)

    this.tabTargets.forEach(tab => {
      const isCurrent = tab.getAttribute("data-tab") === selectedTab
      if (isCurrent) {
        tab.classList.remove("text-gray-600", "hover:text-gray-900")
        tab.classList.add("bg-white", "text-blue-600", "shadow-sm")
      } else {
        tab.classList.remove("bg-white", "text-blue-600", "shadow-sm")
        tab.classList.add("text-gray-600", "hover:text-gray-900")
      }
    })

    this.filter()
  }

  filter() {
    if (!this.hasInputTarget) return
    const query = this.inputTarget.value.toLowerCase().trim()
    sessionStorage.setItem("chat_search_query", this.inputTarget.value)
    
    const activeTab = this.activeTab || "all"
    
    let visibleRooms = 0
    let visibleUsers = 0

    this.roomTargets.forEach(room => {
      const name = (room.getAttribute("data-search-name") || "").toLowerCase()
      const type = room.getAttribute("data-chat-type")
      
      const matchesSearch = name.includes(query)
      const matchesTab = (activeTab === "all") || (activeTab === type)

      if (matchesSearch && matchesTab) {
        room.classList.remove("hidden")
        visibleRooms++
      } else {
        room.classList.add("hidden")
      }
    })

    this.userTargets.forEach(user => {
      const name = (user.getAttribute("data-search-name") || "").toLowerCase()
      if (name.includes(query) && query.length > 0) {
        user.classList.remove("hidden")
        visibleUsers++
      } else {
        user.classList.add("hidden")
      }
    })

    // Show/hide section headers
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
