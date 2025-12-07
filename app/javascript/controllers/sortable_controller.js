import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs";

// Connects to data-controller="sortable"
//This file is controller that uses the SortableJS library to add the
// drag and drop "sorting" funtion to our gifts in gift lists
export default class extends Controller {
    static values = {
        // group option is whatt lets us drag items
        // between multiple lists that share the same group name
        group: String
    }
  connect() {
      Sortable.create(this.element, {

          group: this.groupValue,
          animation: 150
      })
  }


}
