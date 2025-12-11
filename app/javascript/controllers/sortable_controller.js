import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs";
//Stimulus Controller is how one would add javascript behavior to our HTML for rails

// Connects to data-controller="sortable"
//This file is controller that uses the SortableJS library to add the
// drag and drop "sorting" funtion to our gifts in gift lists
// this 3rd party library handles the math of dragging the element, calculating where it drops
export default class extends Controller {
    // stimulus targets allow you to reference DOm elements
    // look for elements with data-sortable-target="column"
    static targets = ["column"]
    // Stimulus values allow passing data from HTML to JS
    static values = { group: String }

    // this is a stimulus lifecycle method that runs automatically when the element is attached to the dom
    connect() {
    // loop through every column target found in the dom
    this.columnTargets.forEach(column => {
        //initialize the sortable library for this colum
        Sortable.create(column, {
          group: this.groupValue,
          animation: 150,

        })
  })
  }

    // function triggered when user clicks save button
    save(event) {
        // loop through each column status
        this.columnTargets.forEach(column => {
            const newStatus = column.dataset.status

            // find all gifts currently sitting in this column
            const gifts = column.querySelectorAll("[data-id]")

            gifts.forEach(gift => {
                // check if the gift's original status is different from the column it is in now
                if (gift.dataset.originalStatus !== newStatus) {
                    this.updateGiftStatus(gift, newStatus)
                }
            })
        })

        // show a saved message in the button, then go back to original after 2 seconds
        const button = event.target;
        const originalText = button.innerText;
        button.innerText = "Saved changes!";
        button.disabled = true;
        setTimeout(() => {
            button.innerText = originalText;
            button.disabled = false;
        }, 2000)
    }

    // helper function that sends the AJAX request to Rails to update gift status
    updateGiftStatus(gift,newStatus) {
        // get the URL for this gift
        const updateUrl = gift.dataset.url;

        // sending ajax request to rails
        // use fetch API for a patch request
        fetch(updateUrl, {
          method: "PATCH", // partial update
          headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              // needed for rails security
              "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
          },
          body: JSON.stringify({gift: {status: newStatus}})
        })
          .then(response => {
              if (!response.ok) {
                  console.error("failed to update gift status");
              }
          });
    }
}

